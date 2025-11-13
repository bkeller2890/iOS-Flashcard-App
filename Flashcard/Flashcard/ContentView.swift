//
//  ContentView.swift
//  Flashcard
//
//  Created by Benjamin Keller on 9/26/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var store = FlashcardStore()
    @State private var showingAddDeck = false
    @State private var showingRemoveDeck = false
    @State private var showingAppearancePicker = false

    @AppStorage("appearance") private var appearance: String = "system"
    @State private var showAppearanceBanner = false
    @State private var bannerMessage = ""

    var body: some View {
        NavigationView {
            List {
                ForEach(store.decks) { deck in
                    NavigationLink(destination: DeckDetailView(deckID: deck.id, store: store)) {
                        Text(deck.name)
                    }
                }
            }
            .navigationTitle("Decks")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingRemoveDeck = true }) {
                        Image(systemName: "trash")
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        Button(action: { showingAppearancePicker = true }) {
                            Image(systemName: "circle.lefthalf.fill")
                        }
                        .accessibilityIdentifier("appearanceButton")

                        Button(action: { showingAddDeck = true }) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
        }

        // OPTIONAL - Appearance indicator
        
        /*
        .overlay(alignment: .top) {
            if showAppearanceBanner {
                Text(bannerMessage)
                    .font(.footnote).bold()
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(.regularMaterial)
                    .clipShape(Capsule())
                    .shadow(radius: 4)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.top, 12)
            }
        }
         
        */


        // Small banner confirmation
        .overlay(alignment: .top) {
            if showAppearanceBanner {
                Text(bannerMessage)
                    .font(.footnote).bold()
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(.regularMaterial)
                    .clipShape(Capsule())
                    .shadow(radius: 4)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.top, 12)
            }
        }

        // Show banner on change
        .onChange(of: appearance) { newValue, _ in
            bannerMessage = "Appearance set to \(newValue.capitalized)"
            withAnimation { showAppearanceBanner = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation { showAppearanceBanner = false }
            }
        }

        // Sheets for adding/removing decks
        .sheet(isPresented: $showingAddDeck) {
            AddDeckView { name, title, subtitle in
                store.addDeck(name: name)
                if let newDeck = store.decks.last, let title = title {
                    store.addChapter(to: newDeck, title: title, subtitle: subtitle)
                }
            }
        }
        .sheet(isPresented: $showingRemoveDeck) {
            RemoveDeckView(decks: $store.decks)
        }

        // 👇 New: Appearance picker sheet
        .sheet(isPresented: $showingAppearancePicker) {
            NavigationView {
                Form {
                    Section(header: Text("Appearance")) {
                        Picker("Appearance", selection: $appearance) {
                            Text("System").tag("system")
                            Text("Light").tag("light")
                            Text("Dark").tag("dark")
                        }
                        .pickerStyle(.segmented)
                    }

                    Section {
                        Button("Reset to System Appearance") {
                            appearance = "system"
                        }
                    } footer: {
                        Text("System: follows iOS appearance. Light/Dark: forces a color scheme for the app.")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
                .navigationTitle("Appearance")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") { showingAppearancePicker = false }
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}


