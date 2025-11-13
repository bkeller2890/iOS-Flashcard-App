//
//  RemoveDeckView.swift
//  Flashcard
//
//  Created by Benjamin Keller on 9/27/25.
//


import SwiftUI


struct RemoveDeckView: View {
    @Environment(\.dismiss) private var dismiss
    
    // The view now binds directly to an array of FlashcardDeck objects.
    @Binding var decks: [FlashcardDeck]
    
    var body: some View {
        NavigationView {
            List {
                // The ForEach iterates over the FlashcardDeck array.
                ForEach(decks) { deck in
                    VStack(alignment: .leading) {
                        // Display the deck name
                        Text(deck.name)
                            .font(.headline)
                        // Display the count of flashcards in the deck
                        Text("\(deck.flashcards.count) cards")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                // .onDelete enables swipe-to-delete functionality.
                .onDelete(perform: deleteDecks)
            }
            .navigationTitle("Remove Decks")
            .toolbar {
                // Done button to dismiss the view.
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                // EditButton enables selection mode for deletion.
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
            }
        }
    }
    
    /// Function to handle the actual deletion from the array of FlashcardDeck.
    func deleteDecks(offsets: IndexSet) {
        // This removes the FlashcardDeck objects at the specified indices from the bound array.
        decks.remove(atOffsets: offsets)
    }
}

// ---

// Note: To make the Preview compile, you'd need your FlashcardStruct defined
// and use it to create example FlashcardDeck objects.


