//
//  CardColor.swift
//  Flashcard
//
//  Created by Benjamin Keller on 9/28/25.
//

import SwiftUI

// Extension to initialize a SwiftUI Color from a Hex String
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0) // Default to white
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    // Extension to convert a SwiftUI Color back to a Hex String (needed for saving)
    func toHexString() -> String {
        guard let components = UIColor(self).cgColor.components else { return "000000" }

        // Handle different color spaces (e.g., Grayscale returns 2 components)
        let r: CGFloat = components.count > 2 ? components[0] : components[0]
        let g: CGFloat = components.count > 2 ? components[1] : components[0]
        let b: CGFloat = components.count > 2 ? components[2] : components[0]
        
        let hex = String(format: "%02lX%02lX%02lX",
                         lround(Double(r * 255)),
                         lround(Double(g * 255)),
                         lround(Double(b * 255)))
        return hex
    }
}
