//
//  ChapterFlashcardView.swift
//  Flashcard
//
//  Created by Benjamin Keller on 11/9/25,  edited on 11/11/25.
//
//

import SwiftUI

struct ChapterFlashcardView: View {
    var deck: FlashcardDeck
    var chapter: ChapterStruct
    @ObservedObject var store: FlashcardStore
    
    @State private var showingManagementView = false
    @State private var showingAddCard = false
    @State private var currentIndex = 0
    @State private var showingAnswer = false
    @State private var shuffleEnabled = false
    @State private var showFavoritesOnly = false
    @State private var shuffledCards: [FlashcardStruct] = []
    
    
    var currentChapter: ChapterStruct? {
        return store.decks.flatMap { $0.chapters }.first{ $0.id == chapter.id }
    }
    
    // Computed property for the active set of cards based on shuffle and favorite filters
    var cards: [FlashcardStruct] {
        // Safely unwrap the current chapter data. If nil, use an empty array.
        guard let freshChapter = currentChapter else { return [] }
        let allCards = shuffleEnabled ? shuffledCards : freshChapter.flashcards
        return showFavoritesOnly ? allCards.filter { $0.isFavorite } : allCards
    }
    
    var body: some View {
        VStack {
            if !cards.isEmpty {
                // IMPORTANT: Safely guard currentIndex to prevent out of bounds errors
                let safeIndex = currentIndex < cards.count ? currentIndex : 0
                let card = cards[safeIndex]
                
                ZStack(alignment: .topTrailing) {
                    Text(showingAnswer ? card.answer : card.question)
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(width: 300, height: 180)
                        .background(card.cardColor)
                        .cornerRadius(12)
                        .shadow(radius: 4)
                        .padding()
                    
                    Button(action: { toggleFavorite(for: card) }) {
                        Image(systemName: card.isFavorite ? "star.fill" : "star")
                            .foregroundColor(card.isFavorite ? .yellow : .gray)
                            .padding()
                    }
                }
                
                if !showingAnswer {
                    Button("Show Answer") { showingAnswer = true }
                        .buttonStyle(.borderedProminent)
                } else {
                    HStack {
                        Button("I Got It Wrong") { nextCard() }.buttonStyle(.bordered)
                        Button("I Got It Right") { nextCard() }.buttonStyle(.borderedProminent)
                    }
                }
                
                Text("\(safeIndex + 1) / \(cards.count)")
                    .font(.caption)
                    .padding(.top, 10)
                
            } else {
                Text(showFavoritesOnly ? "No favorite cards found." : "No flashcards yet. Add some!")
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
        .navigationTitle(currentChapter?.title ?? chapter.title)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Button(action: { showingManagementView = true }) {
                        Image(systemName: "pencil.circle")
                    }
                    Button(action: { showingAddCard = true }) {
                        Image(systemName: "plus")
                    }
                    Button(action: toggleShuffle) {
                        Image(systemName: shuffleEnabled ? "shuffle.circle.fill" : "shuffle.circle")
                    }
                    Button(action: {
                        showFavoritesOnly.toggle()
                        // When filters change, reset index to safely view the new list
                        resetCardView()
                    }) {
                        Image(systemName: showFavoritesOnly ? "star.fill" : "star")
                            .foregroundColor(showFavoritesOnly ? .yellow : .gray)
                    }
                }
            }
        }
        .sheet(isPresented: $showingManagementView) {
            if let deckIndex = store.decks.firstIndex(where: { $0.id == deck.id }),
               let chapterIndex = store.decks[deckIndex].chapters.firstIndex(where: { $0.id == chapter.id }) {
                
                ChapterManagementView(deck: deck,
                                      chapter: $store.decks[deckIndex].chapters[chapterIndex],
                                      store: store)
            }
            else{
                Text("Error: Chapter not found.")
            }
        }
        .sheet(isPresented: $showingAddCard) {
            AddFlashcardView { question, answer, color in
                store.addFlashcard(to: chapter, in: deck,
                                 question: question,
                                 answer: answer,
                                 cardColorHex: color)
                
                // CRITICAL FIX: Reset state after adding card to include it in shuffled list
                // and set currentIndex to a safe value (0).
                resetCardView()
            }
        }
        .onAppear {
            // Initialize the state when the view appears
            resetCardView()
        }
        // Use onChange to reset index if the filtering/shuffling causes the
        // current card to disappear (e.g., toggling to favorites when the current
        // card is not a favorite).
        .onChange(of: cards.count) {
            // If the filtered list changes size, ensure currentIndex is safe.
            if currentIndex >= cards.count && cards.count > 0 {
                currentIndex = 0
            } else if cards.count == 0 {
                currentIndex = 0
            }
        }
    }
    
    // Helper to reset the index and ensure shuffledCards is up-to-date
    private func resetCardView() {
        currentIndex = 0
        
        let freshCards = currentChapter?.flashcards ?? []
        
        shuffledCards = freshCards.shuffled()
        showingAnswer = false
    }
    
    private func nextCard() {
        showingAnswer = false
        // Use the 'cards' computed property which reflects filters/shuffle
        if currentIndex < cards.count - 1 {
            currentIndex += 1
        } else {
            // Reached the end, wrap around to the first card (0)
            currentIndex = 0
            
            // If shuffle is enabled, re-shuffle for a new round
            if shuffleEnabled {
                shuffledCards = currentChapter?.flashcards.shuffled() ?? []
            }
        }
    }
    
    private func toggleShuffle() {
        shuffleEnabled.toggle()
        // Reset view state when shuffling status changes
        resetCardView()
    }
    
    private func toggleFavorite(for card: FlashcardStruct) {
        store.toggleFavorite(for: card, in: chapter, of: deck)
        
        // If we are currently showing favorites only, toggling the favorite state
        // of the current card might make it disappear from the 'cards' array,
        // potentially causing the index error. We call reset to be safe.
        if showFavoritesOnly {
            resetCardView()
        }
    }
}
