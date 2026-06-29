//
//  MovementCatalogFilterSheet.swift
//  Lumberjacked
//

import SwiftUI

struct BodyPartFilterSheet: View {
    @Binding var selectedBodyParts: Set<BodyPart>
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            List {
                ForEach(BodyPart.Category.allCases, id: \.self) { category in
                    let parts = (category == .broad
                        ? BodyPart.cases(in: category)
                        : BodyPart.cases(in: category).sorted { $0.displayName < $1.displayName })
                        .filter { searchText.isEmpty || $0.displayName.localizedCaseInsensitiveContains(searchText) }
                    if !parts.isEmpty {
                        Section(category.rawValue) {
                            ForEach(parts, id: \.self) { part in
                                HStack {
                                    Text(part.displayName)
                                    Spacer()
                                    if selectedBodyParts.contains(part) {
                                        Image(systemName: "checkmark")
                                            .fontWeight(.semibold)
                                            .foregroundStyle(.tint)
                                    }
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    if selectedBodyParts.contains(part) {
                                        selectedBodyParts.remove(part)
                                    } else {
                                        selectedBodyParts.insert(part)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .navigationTitle("Body Part")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Clear") { selectedBodyParts = [] }
                        .disabled(selectedBodyParts.isEmpty)
                }
            }
        }
    }
}

struct ResistanceTypeFilterSheet: View {
    @Binding var selectedResistanceTypes: Set<ResistanceType>

    var body: some View {
        NavigationStack {
            List {
                ForEach(ResistanceType.allCases, id: \.self) { type in
                    HStack {
                        Text(type.displayName)
                        Spacer()
                        if selectedResistanceTypes.contains(type) {
                            Image(systemName: "checkmark")
                                .fontWeight(.semibold)
                                .foregroundStyle(.tint)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if selectedResistanceTypes.contains(type) {
                            selectedResistanceTypes.remove(type)
                        } else {
                            selectedResistanceTypes.insert(type)
                        }
                    }
                }
            }
            .navigationTitle("Resistance Type")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Clear") { selectedResistanceTypes = [] }
                        .disabled(selectedResistanceTypes.isEmpty)
                }
            }
        }
    }
}
