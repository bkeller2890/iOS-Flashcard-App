//
//  FlashcardStruct.swift
//  Flashcard
//
//  Created by Benjamin Keller on 9/26/25.
//
import Foundation
import SwiftUI

struct FlashcardStruct: Identifiable, Codable {
    let id: UUID
    var question: String
    var answer: String
    var cardColorHex: String
    var isFavorite: Bool
    var cardColor: Color{
        return Color(hex: cardColorHex)
    }
    
    
    init(id: UUID = UUID(), question: String, answer: String, cardColorHex: String, isFavorite: Bool = false) {
        self.id = id
        self.question = question
        self.answer = answer
        self.cardColorHex = cardColorHex
        self.isFavorite = isFavorite
    }
}


