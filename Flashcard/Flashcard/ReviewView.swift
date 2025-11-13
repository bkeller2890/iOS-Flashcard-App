//
//  ReviewView.swift
//  Flashcard
//
//  Created by Benjamin Keller on 9/28/25.
//
import SwiftUI

struct ReviewView: View {
    var deck: FlashcardDeck
    @Binding var currentIndex: Int
    @State private var reviewFinished = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            if deck.flashcards.isEmpty {
                Text("No flashcards in this deck.")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .padding()
            } else if reviewFinished {
                // Finished Screen
                VStack(spacing: 20) {
                    Text("🎉 Review Finished!")
                        .font(.largeTitle)
                        .bold()
                    
                    Text("You reviewed all \(deck.flashcards.count) cards.")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        currentIndex = 0
                        reviewFinished = false
                    }) {
                        Text("Restart Review")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(12)
                            .padding(.horizontal)
                    }
                }
                .padding()
            } else {
                // Normal Review Mode
                let total = Double(deck.flashcards.count)
                ProgressView(value: Double(currentIndex + 1),
                             total: total)
                    .padding(.horizontal)
                    .animation(.easeInOut, value: currentIndex)
                
                Text("Card \(currentIndex + 1) of \(deck.flashcards.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 8)
                
                // Clamp index safety
                let safeIndex = min(max(0, currentIndex), deck.flashcards.count - 1)

                FlashcardView(
                    flashcard: deck.flashcards[safeIndex],
                    onSwipeLeft: {
                        if currentIndex < deck.flashcards.count - 1 {
                            withAnimation {
                                currentIndex += 1
                            }
                        } else {
                            withAnimation {
                                reviewFinished = true
                            }
                        }
                    },
                    onSwipeRight: {
                        if currentIndex > 0 {
                            withAnimation {
                                currentIndex -= 1
                            }
                        }
                    }
                )
                .accessibilityElement()
                .accessibilityLabel(Text("Flashcard \(safeIndex + 1) of \(deck.flashcards.count)"))
                .accessibilityHint(Text("Double tap to flip. Swipe left or right to navigate"))
            }
        }
        .navigationTitle(deck.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
            }
        }
    }
}



