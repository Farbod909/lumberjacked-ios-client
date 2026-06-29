//
//  MovementInputView.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/22/25.
//

import SwiftUI

struct MovementInputView: View {
    @State var viewModel: ViewModel
    @Binding var newlyAddedMovement: Movement?
    @Environment(\.dismiss) var dismiss
    @State private var showBodyPartPicker = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    // Group 1: Name
                    VStack(spacing: 0) {
                        MovementInputTextFieldView(
                            placeholderText: "Name",
                            stickyText: "Name",
                            text: $viewModel.movement.name,
                            capitalizeWords: true)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .fieldError(viewModel.fieldErrors["name"])
                    }
                    .brandCard()

                    // Group 2: Body Part + Resistance Type
                    VStack(spacing: 0) {
                        selectionRow(
                            label: "Body Part",
                            displayValue: viewModel.movement.body_part
                                .flatMap { BodyPart(rawValue: $0) }?.displayName)
                        .contentShape(Rectangle())
                        .onTapGesture { showBodyPartPicker = true }

                        Divider().padding(.leading, 16)

                        Menu {
                            Button {
                                viewModel.movement.resistance_type = nil
                            } label: {
                                if viewModel.movement.resistance_type == nil {
                                    Label("None", systemImage: "checkmark")
                                } else {
                                    Text("None")
                                }
                            }
                            ForEach(ResistanceType.allCases, id: \.self) { type in
                                Button {
                                    viewModel.movement.resistance_type = type.rawValue
                                } label: {
                                    if viewModel.movement.resistance_type == type.rawValue {
                                        Label(type.displayName, systemImage: "checkmark")
                                    } else {
                                        Text(type.displayName)
                                    }
                                }
                            }
                        } label: {
                            selectionRow(
                                label: "Resistance Type",
                                displayValue: viewModel.movement.resistance_type
                                    .flatMap { ResistanceType(rawValue: $0) }?.displayName)
                        }
                        .foregroundStyle(.primary)
                    }
                    .brandCard()

                    // Group 3: Notes
                    VStack(spacing: 0) {
                        TextField("Notes", text: $viewModel.movement.notes, axis: .vertical)
                            .textFieldStyle(.plain)
                            .textInputAutocapitalization(.sentences)
                            .lineLimit(1...)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .fieldError(viewModel.fieldErrors["notes"])
                    }
                    .brandCard()
                }
                .padding()
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color.brandBackground.ignoresSafeArea())
            .sheet(isPresented: $showBodyPartPicker) {
                BodyPartPickerSheet(selectedBodyPart: $viewModel.movement.body_part)
            }
            .navigationTitle(viewModel.movement.name == "" ? "New Movement" : viewModel.movement.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task {
                            if viewModel.movement.id == nil {
                                if let movement = await viewModel.attemptSaveNewMovement(
                                    dismissAction: { dismiss() }) {
                                    newlyAddedMovement = movement
                                }
                            } else {
                                await viewModel.attemptUpdateMovement(
                                    dismissAction: { dismiss() })
                            }
                        }
                    } label: {
                        if viewModel.saveActionLoading {
                            ProgressView()
                        } else {
                            Text("Save")
                        }
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onDisappear {
                viewModel.movement = Movement(name: "", notes: "")
            }
            .interactiveDismissDisabled()
            .alert(item: $viewModel.alert)
        }
    }

    private func selectionRow(label: String, displayValue: String?) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(displayValue ?? "None")
                .foregroundStyle(displayValue != nil ? Color.accentColor : Color.secondary)
            Image(systemName: "chevron.up.chevron.down")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .foregroundStyle(.primary)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

struct MovementInputTextFieldView: View {
    var placeholderText: String
    var stickyText: String
    @Binding var text: String
    var capitalizeWords = false

    var body: some View {
        HStack {
            TextField(placeholderText, text: $text)
                .textFieldStyle(.plain)
                .textInputAutocapitalization(capitalizeWords ? .words : .sentences)
            if !text.isEmpty {
                Text(stickyText)
                    .textCase(.uppercase)
                    .font(.caption)
                    .fontWeight(.semibold)
            }
        }
        .animation(.default, value: text)
    }
}

#if DEBUG
#Preview("New Movement") {
    MovementInputView(
        viewModel: MovementInputView.ViewModel(
            movement: Movement(name: "", notes: ""),
            api: MockMovementAPI()),
        newlyAddedMovement: .constant(nil))
}

#Preview("Edit Movement — All Fields") {
    MovementInputView(
        viewModel: MovementInputView.ViewModel(movement: PreviewData.benchPress, api: MockMovementAPI()),
        newlyAddedMovement: .constant(nil))
}

#Preview("Edit Movement — Sparse") {
    MovementInputView(
        viewModel: MovementInputView.ViewModel(movement: PreviewData.cableRow, api: MockMovementAPI()),
        newlyAddedMovement: .constant(nil))
}
#endif
