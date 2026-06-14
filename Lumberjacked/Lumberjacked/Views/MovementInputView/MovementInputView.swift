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

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    MovementInputTextFieldView(
                        placeholderText: "Movement name",
                        stickyText: "Name",
                        text: $viewModel.movement.name,
                        capitalizeWords: true)
                    .fieldError(viewModel.fieldErrors["name"])
                    MovementInputTextFieldView(
                        placeholderText: "Notes",
                        stickyText: "Notes",
                        text: $viewModel.movement.notes)
                    .fieldError(viewModel.fieldErrors["notes"])
                }
            }
            .listRowSpacing(10)
            .navigationTitle(viewModel.movement.name == "" ?
                             "New Movement" : viewModel.movement.name)
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
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onDisappear() {
                viewModel.movement = Movement(name: "", notes: "")
            }
            .interactiveDismissDisabled()
            .alert(item: $viewModel.alert)
        }
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
