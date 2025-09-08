//
//  CompletionNotesView.swift
//  BookingsHQ
//
//  Created by Riley Martin on 4/9/2025.
//

import SwiftUI

struct CompletionNotesView: View {
    @Binding var completionNotes: String
    @Environment(\.dismiss) private var dismiss
    let onSave: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Add Completion Notes")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notes")
                        .font(.headline)
                    TextEditor(text: $completionNotes)
                        .frame(height: 200)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .background(Color(.systemBackground))
                        .cornerRadius(8)
                }
                
                Spacer()
                
                VStack(spacing: 12) {
                    Button("Complete Job") {
                        onSave()
                        dismiss()
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
                    
                    Button("Cancel") {
                        onCancel()
                        dismiss()
                    }
                    .font(.headline)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.blue, lineWidth: 2)
                    )
                }
            }
            .padding()
            .navigationTitle("Job Completion")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
