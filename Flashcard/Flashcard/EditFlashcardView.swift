//
//  EditFlashcardView.swift
//  Flashcard
//
//  Created by Benjamin Keller on 9/28/25.
//

import SwiftUI

// Assume this view is used to create or edit a flashcard
struct EditFlashcardView: View {
    // This binding allows us to directly update the FlashcardStruct
    @Binding var flashcard: FlashcardStruct
    
    // State to hold the Color object that the ColorPicker will use
    @State private var selectedColor: Color
    
    init(flashcard: Binding<FlashcardStruct>) {
        self._flashcard = flashcard
        // Initialize the State from the struct's hex string
        self._selectedColor = State(initialValue: flashcard.wrappedValue.cardColor)
    }
    
    var body: some View {
        Form {
            TextField("Question", text: $flashcard.question, axis: .vertical)
            TextField("Answer", text: $flashcard.answer, axis: .vertical)
            
            // Allow the user to pick the color
            ColorPicker("Card Color", selection: $selectedColor)
            
            // Use onChange to automatically update the storable hex string
            // whenever the user selects a new color.
            .onChange(of: selectedColor) { oldValue, newColor in
                flashcard.cardColorHex = newColor.toHexString()
            }
        }
        .navigationTitle("Edit Card")
        // Optional: Show a preview of the card color
        .background(selectedColor.opacity(0.1))
    }
}
