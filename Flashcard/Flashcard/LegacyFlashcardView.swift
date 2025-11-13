//
//  LegacyFlashcardView.swift
//  Flashcard
//
// Created by: Benjamin Keller on 11/9/2025
//
//

import SwiftUI

// NOTE: This code assumes the existence of the following structs/classes:
// FlashcardDeck, FlashcardStore, FlashcardStruct.
// FlashcardStruct should contain properties: id, question, answer, isFavorite, cardColor.

struct LegacyFlashcardView: View {
    var deck: FlashcardDeck
    @ObservedObject var store: FlashcardStore
    
    // MARK: - State Properties
    @State private var currentIndex = 0
    @State private var showingAnswer = false
    @State private var showingAddCard = false
    @State private var showingRemoveFlashcards = false
    @State private var shuffleEnabled = false
    @State private var shuffledCards: [FlashcardStruct] = []
    @State private var showFavoritesOnly = false
    
    private var firstChapter: ChapterStruct? {
        guard let currentDeck = store.decks.first(where: { $0.id == deck.id }) else { return nil}
        return currentDeck.chapters.first
    }
    
    // MARK: - Computed Properties for Card Logic
    private var currentCards: [FlashcardStruct] {
        let sourceCards = firstChapter?.flashcards ?? []
        let allCards = shuffleEnabled ? shuffledCards : sourceCards
        return showFavoritesOnly ? allCards.filter { $0.isFavorite } : allCards
    }
    
    // MARK: - Body
    var body: some View {
        VStack {
            
            let cards = currentCards
            
            if !cards.isEmpty, let card = cards.indices.contains(currentIndex) ? cards[currentIndex] : nil {
                
                // MARK: Flashcard Display
                ZStack(alignment: .topTrailing) {
                    Text(showingAnswer ? card.answer : card.question)
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                        .frame(width: 300, height: 180)
                        .background(card.cardColor)
                        .cornerRadius(16)
                        .shadow(color: Color.gray.opacity(0.4), radius: 6, x: 0, y: 3)
                        .padding()
                        .onTapGesture {
                            showingAnswer.toggle()
                        }
                    
                    // Favorite toggle button
                    Button(action: { toggleFavorite(for: card) }) {
                        Image(systemName: card.isFavorite ? "star.fill" : "star")
                            .font(.title2)
                            .foregroundColor(card.isFavorite ? .yellow : .gray.opacity(0.7))
                            .padding(20) // Increase tap target size
                    }
                }
                
                Spacer()
                
                // MARK: Answer/Navigation Buttons
                if !showingAnswer {
                    Button("Show Answer") {
                        showingAnswer = true
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                } else {
                    HStack(spacing: 20) {
                        Button("I Got It Wrong") {
                            goToNextCard(cards: cards)
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                        
                        Button("I Got It Right") {
                            goToNextCard(cards: cards)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                    }
                }
            } else {
                Text("No flashcards yet. Add some!")
                    .font(.title)
                    .foregroundColor(.secondary)
                    .padding(.top, 50)
            }
        }
        .navigationTitle(deck.name)
        .onAppear {
            // Initialize shuffled cards using the chapter's data
            refreshShuffledCards()
        }
        
        // MARK: - Modifiers and Sheets
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { showingRemoveFlashcards = true }) {
                    Image(systemName: "trash")
                }
            }
            
            ToolbarItem(placement: .principal) {
                // Binding for ReviewView progress
                let progressBinding = Binding<Int>(
                    get: { store.reviewProgress[deck.id] ?? 0 },
                    set: { store.reviewProgress[deck.id] = $0 }
                )
                
                NavigationLink {
                    // Assuming ReviewView exists and takes a deck and index binding
                    ReviewView(deck: deck, currentIndex: progressBinding)
                } label: {
                    Text("Review")
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Button(action: { showingAddCard = true }) {
                        Image(systemName: "plus")
                    }
                    
                    Button(action: toggleShuffle) {
                        Image(systemName: shuffleEnabled ? "shuffle.circle.fill" : "shuffle.circle")
                    }
                    
                    // Filter favorites button
                    Button(action: { showFavoritesOnly.toggle() }) {
                        Image(systemName: showFavoritesOnly ? "heart.fill" : "heart")
                            .foregroundColor(showFavoritesOnly ? .pink : .gray)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddCard) {
            AddFlashcardView { question, answer, cardColorHex in
                
                if let chapter = firstChapter {store.addFlashcard(to: chapter, in: deck, question: question, answer: answer, cardColorHex: cardColorHex)}
                // Fix: Refresh shuffled cards directly from the store's updated deck data.
                refreshShuffledCards()
            }
        }
        .sheet(isPresented: $showingRemoveFlashcards) { // Renaming state variable would be cleaner but this works
            if let deckIndex = store.decks.firstIndex(where: { $0.id == deck.id }),
               let chapterIndex = store.decks[deckIndex].chapters.firstIndex(where: { $0.id == firstChapter?.id }) {
                
                ChapterManagementView(
                    deck: deck,
                    chapter: $store.decks[deckIndex].chapters[chapterIndex],
                    store: store
                )
            } else {
                Text("Error: Chapter data not found.")
            }
        }
    }
    
    // MARK: - Private Helper Functions
    
    // New helper to safely update the shuffledCards array from the store's current state.
    private func refreshShuffledCards() {
        shuffledCards = firstChapter?.flashcards.shuffled() ?? []
    }

    
    private func goToNextCard(cards: [FlashcardStruct]) {
        showingAnswer = false
        if currentIndex < cards.count - 1 {
            currentIndex += 1
        } else {
            // Loop back to the start
            currentIndex = 0
            // If shuffling is enabled, re-shuffle the original list for a new sequence
            if shuffleEnabled {
                refreshShuffledCards()
            }
        }
    }
    
    private func toggleShuffle() {
        shuffleEnabled.toggle()
        currentIndex = 0
        if shuffleEnabled {
            refreshShuffledCards()
        }
    }
    
    private func toggleFavorite(for card: FlashcardStruct) {
        // FIX: Must now find the chapter index as well
        guard let deckIndex = store.decks.firstIndex(where: { $0.id == deck.id }),
              let chapterIndex = store.decks[deckIndex].chapters.firstIndex(where: { $0.id == firstChapter?.id }),
              let cardIndex = store.decks[deckIndex].chapters[chapterIndex].flashcards.firstIndex(where: { $0.id == card.id })
        else {
            return
        }
        // FIX: Access the card via the chapter index
        store.decks[deckIndex].chapters[chapterIndex].flashcards[cardIndex].isFavorite.toggle()
        
        // ... rest of the logic uses currentCards, which is now fixed to use the chapter
        if showFavoritesOnly && !store.decks[deckIndex].chapters[chapterIndex].flashcards[cardIndex].isFavorite {
            if currentIndex >= currentCards.count {
                currentIndex = currentCards.isEmpty ? 0 : currentCards.count - 1
            }
        }
    }
}
