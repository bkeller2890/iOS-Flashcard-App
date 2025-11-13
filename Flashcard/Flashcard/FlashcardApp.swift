//
//  FlashcardApp.swift
//  Flashcard
//
//  Created by Benjamin Keller on 9/26/25.
//

import SwiftUI
import SwiftData

@main
struct FlashcardApp: App {
    @AppStorage("appearance") private var appearance = "system"

    // Shared Model Container
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
            // Add more models here later (e.g., Deck.self, Chapter.self)
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    // Main Scene
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(colorScheme(for: appearance))
        }
        .modelContainer(sharedModelContainer)
    }

    // Appearance Helper
    private func colorScheme(for value: String) -> ColorScheme? {
        switch value {
        case "light": return .light
        case "dark": return .dark
        default: return nil // "system" or any other default
        }
    }
}
