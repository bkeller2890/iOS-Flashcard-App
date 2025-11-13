//
//  Item.swift
//  Flashcard
//
//  Created by Benjamin Keller on 9/26/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
