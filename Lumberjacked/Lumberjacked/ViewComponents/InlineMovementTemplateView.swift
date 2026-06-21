//
//  InlineMovementTemplateView.swift
//  Lumberjacked
//

import SwiftUI

struct InlineMovementTemplateView: View {
    let movement: Movement
    @Binding var movementNotes: String
    @Binding var templateSets: [TemplateSet]
    var onReorderTapped: (() -> Void)? = nil
    var onReplaceTapped: (() -> Void)? = nil
    var onRemoveTapped: (() -> Void)? = nil

    @State private var showMovementNotesField = false
    @State private var hideMovementNotes = false

    private var movementNotesVisible: Bool {
        (!movementNotes.isEmpty || showMovementNotesField) && !hideMovementNotes
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            HStack(alignment: .center) {
                Text(movement.name)
                    .font(DesignSystem.Font.cardTitle)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Menu {
                    if !movementNotesVisible {
                        Button("Add note to \(movement.name)", systemImage: "plus.bubble") {
                            hideMovementNotes = false
                            showMovementNotesField = true
                        }
                    }
                    if movementNotesVisible && movementNotes.isEmpty {
                        Button("Hide \(movement.name) note", systemImage: "eye.slash") {
                            hideMovementNotes = true
                            showMovementNotesField = false
                        }
                    }

                    if let reorder = onReorderTapped {
                        Button("Reorder", systemImage: "line.3.horizontal") {
                            reorder()
                        }
                    }

                    if let replace = onReplaceTapped {
                        Button("Replace", systemImage: "arrow.left.arrow.right") {
                            replace()
                        }
                    }

                    if let remove = onRemoveTapped {
                        Button("Remove", systemImage: "minus.circle", role: .destructive) {
                            remove()
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 8)

            if movementNotesVisible {
                TextField(
                    "",
                    text: $movementNotes,
                    prompt: Text("Movement notes...").foregroundStyle(Color.accentColor.opacity(0.5))
                )
                .font(.subheadline)
                .foregroundStyle(.primary)
                .tint(.accentColor)
                .lineLimit(1)
                .padding(.horizontal, 12)
                .padding(.vertical, 11)
                .background(Color.accentColor.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
                .padding(.horizontal, 10)
                .padding(.bottom, 4)
            }

            SetLogInputView(mode: .editTemplate, templateSets: $templateSets, isEmbedded: true)
        }
    }
}
