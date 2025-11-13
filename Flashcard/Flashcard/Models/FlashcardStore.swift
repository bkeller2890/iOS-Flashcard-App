//  FlashcardStore.swift
//  Flashcard
//
//  Created by Benjamin Keller on 9/27/25.
//  Edited on 9/28/25 
//

import Foundation
import Combine
import SwiftUI

class FlashcardStore: ObservableObject {
    
    @Published var decks: [FlashcardDeck] = [] {
        didSet {
            save()
        }
    }
    
    /// Persisted per-deck review progress: deck id -> last index
    @Published var reviewProgress: [UUID: Int] = [:] {
        didSet {
            saveReviewProgress()
        }
    }
        
    private let saveKey = "decks"
    private let reviewProgressKey = "reviewProgress"
        
    init() {
        load()
    }
    
    // --- Deck Management ---
        
    func addDeck(name: String) {
        let newDeck = FlashcardDeck(name: name, chapters: []) // Assuming you updated FlashcardDeck struct
        decks.append(newDeck)
    }
        
    func removeDeck(_ deck: FlashcardDeck){
        decks.removeAll{ $0.id == deck.id}
    }
    
    // --- Chapter Management ---
    
    func addChapter(to deck: FlashcardDeck,
                    title: String,
                    subtitle: String? = nil) {
          guard let index = decks.firstIndex(where: { $0.id == deck.id }) else { return }
          let newChapter = ChapterStruct(title: title, subtitle: subtitle)
          decks[index].chapters.append(newChapter)
    }
    
    func removeChapter(from deck: FlashcardDeck, chapter: ChapterStruct) {
        guard let deckIndex = decks.firstIndex(where: { $0.id == deck.id }) else { return }
          decks[deckIndex].chapters.removeAll { $0.id == chapter.id }
    }
    
    // 💡 CRITICAL ADDITION: Centralized function to update an entire chapter
    func updateChapter(_ updatedChapter: ChapterStruct, in deck: FlashcardDeck) {
        // 1. Find the deck index
        guard let deckIndex = decks.firstIndex(where: { $0.id == deck.id }) else { return }
        
        // 2. Find the chapter index
        guard let chapterIndex = decks[deckIndex].chapters.firstIndex(where: { $0.id == updatedChapter.id }) else { return }
        
        // 3. Replace the old chapter with the updated one (includes moved/deleted cards)
        decks[deckIndex].chapters[chapterIndex] = updatedChapter
    }

    // --- Flashcard Management (within Chapter) ---
        
    func addFlashcard(to chapter: ChapterStruct,
                      in deck: FlashcardDeck,
                      question: String,
                      answer: String,
                      cardColorHex: String) {
              guard let deckIndex = decks.firstIndex(where: { $0.id == deck.id }) else { return }
              guard let chapterIndex = decks[deckIndex].chapters.firstIndex(where: { $0.id == chapter.id }) else { return }
              
              let newCard = FlashcardStruct(question: question, answer: answer, cardColorHex: cardColorHex)
              decks[deckIndex].chapters[chapterIndex].flashcards.append(newCard)
          }
    
    func toggleFavorite(for card: FlashcardStruct, in chapter: ChapterStruct, of deck: FlashcardDeck) {
        guard let deckIndex = decks.firstIndex(where: { $0.id == deck.id }),
              let chapterIndex = decks[deckIndex].chapters.firstIndex(where: { $0.id == chapter.id }),
              let cardIndex = decks[deckIndex].chapters[chapterIndex].flashcards.firstIndex(where: { $0.id == card.id })
        else { return }
        
        decks[deckIndex].chapters[chapterIndex].flashcards[cardIndex].isFavorite.toggle()
    }

    // --- Save & Load ---
        
    private func save() {
        if let encoded = try? JSONEncoder().encode(decks) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
        
    private func saveReviewProgress() {
        if let encoded = try? JSONEncoder().encode(reviewProgress) {
            UserDefaults.standard.set(encoded, forKey: reviewProgressKey)
        }
    }
        
    private func load() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
          let decoded = try? JSONDecoder().decode([FlashcardDeck].self, from: data) {
            decks = decoded
        }
        // load review progress
        if let data = UserDefaults.standard.data(forKey: reviewProgressKey),
          let decoded = try? JSONDecoder().decode([UUID: Int].self, from: data) {
            reviewProgress = decoded
        }
    }
}
