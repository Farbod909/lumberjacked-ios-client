//
//  MovementReplaceSheet.swift
//  Lumberjacked
//

import SwiftUI

struct MovementReplaceSheet: View {
    let allMovements: [Movement]
    let onSelect: (Movement) -> Void

    @State private var searchText = ""
    @FocusState private var searchFocused: Bool
    @Environment(\.dismiss) private var dismiss

    var searchResults: [Movement] {
        searchText.isEmpty ? [] : allMovements.filter {
            $0.name.lowercased().contains(searchText.lowercased())
        }
    }

    var body: some View {
        NavigationStack {
            List {
                HStack {
                    TextField("Search movements...", text: $searchText)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .keyboardType(.alphabet)
                        .focused($searchFocused)
                }
                .listRowBackground(Color.clear)

                ForEach(searchResults, id: \.self) { movement in
                    Button(movement.name) {
                        onSelect(movement)
                        dismiss()
                    }
                    .foregroundColor(.primary)
                }
            }
            .listStyle(.inset)
            .navigationTitle("Replace With")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .onAppear { searchFocused = true }
    }
}
