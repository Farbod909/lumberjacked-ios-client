//
//  BodyPartPickerSheet.swift
//  Lumberjacked
//

import SwiftUI

struct BodyPartPickerSheet: View {
    @Binding var selectedBodyPart: String?
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
        List {
            row(label: "None", selected: selectedBodyPart == nil || selectedBodyPart == "") {
                selectedBodyPart = nil
                dismiss()
            }

            ForEach(BodyPart.Category.allCases, id: \.self) { category in
                let options = BodyPart.cases(in: category).filter { matches($0) }
                if !options.isEmpty {
                    Section(category.rawValue) {
                        ForEach(options, id: \.self) { part in
                            row(label: part.displayName, selected: selectedBodyPart == part.rawValue) {
                                selectedBodyPart = part.rawValue
                                dismiss()
                            }
                        }
                    }
                }
            }
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        .contentMargins(.top, 6, for: .scrollContent)
        .navigationTitle("Body Part")
        .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func row(label: String, selected: Bool, onTap: @escaping () -> Void) -> some View {
        HStack {
            Text(label)
            Spacer()
            if selected {
                Image(systemName: "checkmark")
                    .fontWeight(.semibold)
                    .foregroundStyle(.tint)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { onTap() }
    }

    private func matches(_ part: BodyPart) -> Bool {
        searchText.isEmpty || part.displayName.localizedCaseInsensitiveContains(searchText)
    }
}
