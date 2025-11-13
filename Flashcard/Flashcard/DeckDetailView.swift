//
//  DeckDetailView.swift
//  Flashcard
//
//  Created by Benjamin Keller on 9/27/25.
//  Edited on 9/29/2025
//

import SwiftUI

struct DeckDetailView: View {
    
    let deckID: UUID
    
    @ObservedObject var store: FlashcardStore
    @State private var showingAddChapter = false
    
    // Computed property to fetch the latest deck from the store (correct)
    var deck: FlashcardDeck? {
        store.decks.first(where: { $0.id == deckID})
    }

    var body: some View {
        Group {
            // Safely unwrap the optional deck
            if let currentDeck = deck {
                if currentDeck.chapters.isEmpty {
                    // Fallback: use your old flat flashcard view
                    LegacyFlashcardView(deck: currentDeck, store: store)
                } else {
                    // New structure: chapters with flashcards
                    List {
                        // The ForEach uses the currentDeck from the 'if let'
                        ForEach(currentDeck.chapters) { chapter in
                            NavigationLink(destination: ChapterFlashcardView(deck: currentDeck, chapter: chapter, store: store)) {
                                VStack(alignment: .leading) {
                                    Text(chapter.title)
                                        .font(.headline)
                                    if let subtitle = chapter.subtitle {
                                        Text(subtitle)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                        // Correctly applies swipe-to-delete
                        .onDelete(perform: deleteChapter)
                    }
                    .navigationTitle(currentDeck.name)
                    
                    // 🚨 RE-INSERTING THE TOOLBAR ITEMS 🚨
                    .toolbar {
                        // EditButton allows the user to easily enter deletion/reordering mode
                        ToolbarItem(placement: .topBarLeading) {
                            EditButton()
                        }
                        // Add Chapter Button
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action: { showingAddChapter = true }) {
                                Label("Add", systemImage: "plus")
                            }
                        }
                    }
                    // Add Chapter Sheet
                    .sheet(isPresented: $showingAddChapter) {
                         // Pass the currentDeck to the addChapter logic
                         AddChapterView { title, subtitle in
                            store.addChapter(to: currentDeck, title: title, subtitle: subtitle)
                        }
                    }
                }
            } else {
                // Handle case where deck is not found (e.g., if deleted elsewhere)
                Text("Deck not found.")
            }
        }
    }
    
    func deleteChapter(offsets: IndexSet) {
        // Ensure the deck is available and find its index in the store
        guard let currentDeck = deck,
              let deckIndex = store.decks.firstIndex(where: { $0.id == currentDeck.id }) else {
            return
        }
        
        // Loop through the indices SwiftUI told us to delete
        for index in offsets {
            // Get the chapter to delete from the *store's* current version of the deck
            let chapterToDelete = store.decks[deckIndex].chapters[index]
            
            // Call the store function to remove the chapter from the data
            store.removeChapter(from: currentDeck, chapter: chapterToDelete)
        }
    }
}
