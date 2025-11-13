//
//  AddChapterView.swift
//  Flashcard
//
//  Created by Benjamin Keller on 11/8/25.
//

import SwiftUI

struct AddChapterView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var type = "Chapter"
    @State private var number = ""
    @State private var subtitle = ""
    
    /// Called when user taps Save
    var onSave: (String, String?) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Picker("Type", selection: $type) {
                    Text("Chapter").tag("Chapter")
                    Text("Exam").tag("Exam")
                    Text("Final Exam").tag("Final Exam")
                }
                .pickerStyle(.segmented)
                
                if type != "Final Exam" {
                    TextField("\(type) Number", text: $number)
                        .keyboardType(.numberPad)
                }
                
                if type == "Chapter" {
                    TextField("Subtitle (optional)", text: $subtitle)
                }
            }
            .navigationTitle("New \(type)")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let title: String
                        if type == "Final Exam" {
                            title = "Final Exam Review"
                        } else {
                            title = "\(type) \(number) Review"
                        }
                        
                        onSave(title, subtitle.isEmpty ? nil : subtitle)
                        dismiss()
                    }
                    .disabled(type != "Final Exam" && number.isEmpty)
                }
            }
        }
    }
}

#Preview {
    AddChapterView { title, subtitle in
        print("Saved: \(title), \(subtitle ?? "No subtitle")")
    }
}
