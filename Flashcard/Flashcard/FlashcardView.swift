import SwiftUI

struct FlashcardView: View {
    // FlashcardStruct now includes the computed 'cardColor' property.
    var flashcard: FlashcardStruct
    var onSwipeLeft: (() -> Void)? = nil
    var onSwipeRight: (() -> Void)? = nil
    
    @State private var flipped = false
    @State private var rotation = 0.0
    @State private var offsetX: CGFloat = 0
    @State private var isSwipedAway = false
    
    // 💡 Helper to use a consistent color for both sides, or a slightly different one
    var cardBackgroundColor: Color {
        // Use the computed property from the struct directly
        flashcard.cardColor
    }
    
    // Optional: Determine a suitable text color based on the card's background color.
    // We'll stick to .white for simplicity and contrast with typical bright colors.
    var cardTextColor: Color {
        .white
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Use rotation angle to decide which side to draw to avoid mirrored text during the 3D flip.
                let normalized = rotation.truncatingRemainder(dividingBy: 360)
                
                if normalized < 90 || normalized > 270 {
                    // Front (Question)
                    RoundedRectangle(cornerRadius: 16)
                        .fill(cardBackgroundColor)
                        .shadow(radius: 8)
                        .overlay(
                            Text(flashcard.question)
                                .font(.title2)
                                //
                                .foregroundColor(cardTextColor)
                                .multilineTextAlignment(.center)
                                .padding()
                                .minimumScaleFactor(0.5)
                        )
                        .accessibilityElement()
                        .accessibilityLabel(Text("Question"))
                        .accessibilityValue(Text(flashcard.question))
                        .accessibilityHint(Text("Double tap to flip. Swipe left for next, swipe right for previous."))
                } else {
                    // Back (Answer) — rotate 180 so it's upright when the container is rotated
                    RoundedRectangle(cornerRadius: 16)
                        // ✅ Use the dynamic color here (you might use a slightly darker shade if you extend Color for that)
                        .fill(cardBackgroundColor)
                        .shadow(radius: 8)
                        .overlay(
                            Text(flashcard.answer)
                                .font(.title2)
                                // ✅ Use dynamic text color
                                .foregroundColor(cardTextColor)
                                .multilineTextAlignment(.center)
                                .padding()
                                .minimumScaleFactor(0.5)
                        )
                        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                        .accessibilityElement()
                        .accessibilityLabel(Text("Answer"))
                        .accessibilityValue(Text(flashcard.answer))
                        .accessibilityHint(Text("Double tap to flip back. Swipe left for next, swipe right for previous."))
                }
            }
            .frame(width: geo.size.width * 0.85, height: geo.size.height * 0.6)
            .rotation3DEffect(.degrees(rotation), axis: (x: 0, y: 1, z: 0))
            .offset(x: offsetX) // follow finger or animate off
            .rotationEffect(.degrees(Double(offsetX / 20)))
            .opacity(1 - min(Double(abs(offsetX)) / 400, 0.6))
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.6)) {
                    rotation += 180
                    // keep rotation in a reasonable range
                    rotation = rotation.truncatingRemainder(dividingBy: 360)
                    flipped.toggle()
                }
            }
            // ... (The rest of the gesture code remains unchanged)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        offsetX = value.translation.width
                    }
                    .onEnded { value in
                        let threshold: CGFloat = 120
                        if value.translation.width < -threshold {
                            withAnimation(.spring()) {
                                offsetX = -geo.size.width
                                isSwipedAway = true
                            }
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                onSwipeLeft?()
                                offsetX = 0
                                isSwipedAway = false
                            }
                        } else if value.translation.width > threshold {
                            withAnimation(.spring()) {
                                offsetX = geo.size.width
                                isSwipedAway = true
                            }
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                onSwipeRight?()
                                offsetX = 0
                                isSwipedAway = false
                            }
                        } else {
                            withAnimation(.interactiveSpring()) { offsetX = 0 }
                        }
                    }
            )
            .position(x: geo.size.width / 2, y: geo.size.height / 2)
        }
    }
}

