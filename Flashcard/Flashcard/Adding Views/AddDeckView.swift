//
//  AddDeckView.swift
//  Flashcard
//
//  Created by Benjamin Keller on 9/27/25.
//

import SwiftUI

struct AddDeckView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var chapterTitle = ""
    @State private var chapterSubtitle = ""
    
    /// Called when user taps Save
    var onSave: (String, String?, String?) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Topic Name")) {
                    TextField("Enter topic name", text: $name)
                }
                Section(header: Text("Chapter (Optional)")){
                    TextField("Chapter title", text:  $chapterTitle)
                    TextField("Chapter subtitle", text: $chapterSubtitle)
                        
                }
            }
            .navigationTitle("New Topic")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if !name.isEmpty {
                            let title = chapterTitle.isEmpty ? nil : chapterTitle
                            let subtitle = chapterSubtitle.isEmpty ? nil : chapterSubtitle
                            onSave(name, title, subtitle)
                            dismiss()
                        }
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

#Preview {
    AddDeckView { name, title, subtitle in
        print("Saved topic: \(name), chapter: \(title ?? "none")")
    }
}
