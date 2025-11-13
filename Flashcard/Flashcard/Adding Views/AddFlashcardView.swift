//
//  AddFlashcardView.swift
//  Flashcard
//
//  Created by Benjamin Keller on 9/27/25.
//

import SwiftUI

struct AddFlashcardView: View {
    @Environment(\.dismiss) var dismiss
    
    // 💡 The closure must accept the color hex string
    var onSave: (String, String, String) -> Void
    
    // State for user input
    @State private var question: String = ""
    @State private var answer: String = ""
    
    // 💡 State for color picker (initialized to a default color)
    @State private var selectedColor: Color = Color(hex: "00A3A3") // Use your default hex
    
    var body: some View {
        NavigationView {
            Form {
                // ... TextFields for question and answer
                TextField("Question", text: $question, axis: .vertical)
                TextField("Answer", text: $answer, axis: .vertical)
                
                // Color Picker for user selection
                ColorPicker("Card Color", selection: $selectedColor)
            }
            .navigationTitle("New Flashcard")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        // FIX APPLIED HERE: Calculate the hex string inside the action
                        let cardColorHex = selectedColor.toHexString()

                        if !question.isEmpty && !answer.isEmpty {
                            // Pass the data to the closure
                            onSave(question, answer, cardColorHex)
                            dismiss()
                        }
                    }
                    .disabled(question.isEmpty || answer.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
#Preview {
    AddFlashcardView { question, answer, cardColorHex in
        print("Saved card: Q: \(question), A: \(answer), Color: #\(cardColorHex)")
    }
}

