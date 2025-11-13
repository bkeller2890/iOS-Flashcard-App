//
//  ChapterManagementView.swift
//  Flashcard
//
//  Created by Benjamin Keller on 11/11/25.
//
import SwiftUI

struct ChapterManagementView: View {
    
    var deck: FlashcardDeck
    @Binding var chapter: ChapterStruct // <-- CRITICAL FIX: Use @Binding
    @ObservedObject var store: FlashcardStore
    
    // Dismiss environment variable
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            List {
                // Display the cards in a list
                // Note: ForEach over a binding property (@Binding var chapter) works fine
                // You do not need ForEach($chapter.flashcards) unless you want to edit individual cards
                ForEach(chapter.flashcards) { card in
                    // Enhanced row display for better clarity during deletion/reordering
                    VStack(alignment: .leading) {
                        Text(card.question)
                            .font(.headline)
                        Text(card.answer)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .onDelete(perform: deleteFlashcard) // Uses the new logic below
                .onMove(perform: moveFlashcard)     // Uses the new logic below
            }
            .navigationTitle("Edit: \(chapter.title)")
            .toolbar {
                // Add the EditButton for deletion/reordering mode
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }
                // Dismiss button for the sheet
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // Deletion function
    func deleteFlashcard(offsets: IndexSet) {
        // 1. Modify the local array first (this updates the @Binding)
        chapter.flashcards.remove(atOffsets: offsets)
        
        // 2. Persist the updated chapter to the store
        store.updateChapter(chapter, in: deck)
    }
    
    // Reordering Function
    func moveFlashcard(from source: IndexSet, to destination: Int) {
        // 1. Modify the local array first (this updates the @Binding)
        chapter.flashcards.move(fromOffsets: source, toOffset: destination)
        
        // 2. Persist the updated chapter to the store
        store.updateChapter(chapter, in: deck)
    }
}
