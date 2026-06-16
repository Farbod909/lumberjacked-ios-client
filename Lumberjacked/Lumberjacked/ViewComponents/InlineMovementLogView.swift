//
//  InlineMovementLogView.swift
//  Lumberjacked
//

import SwiftUI

struct InlineMovementLogView: View {
    let movement: Movement
    @Binding var movementNotes: String   // editable when movementNotesEditable, otherwise ignored
    @Binding var logNotes: String
    @Binding var logSets: [LogSet]
    let mode: SetLogInputMode
    let movementNotesEditable: Bool
    var readOnly: Bool = false
    var onReorderTapped: (() -> Void)? = nil
    var onEditTapped: (() -> Void)? = nil
    var onRemoveTapped: (() -> Void)? = nil

    // showXField: user opened the field via menu on an otherwise-empty note
    // hideX: user collapsed the field (even if it has content)
    @State private var showLogNotesField = false
    @State private var hideLogNotes = false
    @State private var showMovementNotesField = false
    @State private var hideMovementNotes = false

    private var logNotesVisible: Bool {
        (!logNotes.isEmpty || showLogNotesField) && !hideLogNotes
    }

    private var movementNotesVisible: Bool {
        (!movement.notes.isEmpty || showMovementNotesField) && !hideMovementNotes
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Movement name + menu
            HStack(alignment: .center) {
                Text(movement.name)
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)

                if let edit = onEditTapped {
                    Button { edit() } label: {
                        Image(systemName: "chevron.right")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                } else if !readOnly {
                    Menu {
                        // Add note options (shown when note is hidden or empty)
                        if !logNotesVisible {
                            Button("Add note to log", systemImage: "plus.bubble") {
                                hideLogNotes = false
                                showLogNotesField = true
                            }
                        }
                        if movementNotesEditable && !movementNotesVisible {
                            Button("Add note to \(movement.name)", systemImage: "plus.bubble") {
                                hideMovementNotes = false
                                showMovementNotesField = true
                            }
                        }

                        // Hide note options (only when the field is visible but empty)
                        if logNotesVisible && logNotes.isEmpty {
                            Button("Hide log note", systemImage: "eye.slash") {
                                hideLogNotes = true
                                showLogNotesField = false
                            }
                        }
                        if movementNotesEditable && movementNotesVisible && movementNotes.isEmpty {
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
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 8)

            // Movement notes
            if movementNotesEditable && movementNotesVisible {
                TextField(
                    "",
                    text: $movementNotes,
                    prompt: Text("Movement notes...").foregroundStyle(Color.accentColor.opacity(0.5))
                )
                .font(.subheadline)
                .foregroundStyle(.primary)
                .tint(.accentColor)
                .lineLimit(1)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.accentColor.opacity(0.12))
                .padding(.bottom, 4)
            } else if !movementNotesEditable && !movement.notes.isEmpty {
                Text(movement.notes)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
            }

            // Log notes
            if readOnly {
                if !logNotes.isEmpty {
                    Text(logNotes)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)
                }
            } else if logNotesVisible {
                TextField(
                    "",
                    text: $logNotes,
                    prompt: Text("Log notes...").foregroundStyle(.tertiary)
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .padding(.bottom, 4)
            }

            SetLogInputView(mode: mode, logSets: $logSets, isEmbedded: true, readOnly: readOnly)
        }
    }
}
