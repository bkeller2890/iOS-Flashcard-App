//
//  ChapterStruct.swift
//  Flashcard
//
//  Created by Benjamin Keller on 11/9/25.
//

import Foundation

struct ChapterStruct: Identifiable, Codable{
    let id: UUID
    var title: String
    var subtitle: String?
    var flashcards: [FlashcardStruct]
    
    init(id: UUID = UUID(), title: String, subtitle: String? = nil, flashcards: [FlashcardStruct] = []){
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.flashcards = flashcards
    }
    
}
