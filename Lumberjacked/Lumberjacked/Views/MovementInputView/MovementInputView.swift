//
//  MovementInputView.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/22/25.
//

import SwiftUI

struct MovementInputView: View {
    @State var viewModel: ViewModel
    @Binding var newlyAddedMovement: Movement? // Binding to tell parent view about a new movement.
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                FormErrors(errors: $viewModel.errors)
                Section {
                    MovementInputTextFieldView(
                        placeholderText: "Movement name",
                        stickyText: "Name",
                        text: $viewModel.movement.name,
                        capitalizeWords: true)
                    .formFieldError($viewModel.errors, "name")
                    MovementInputTextFieldView(
                        placeholderText: "Category",
                        stickyText: "Category",
                        text: $viewModel.movement.category,
                        capitalizeWords: true)
                    .formFieldError($viewModel.errors, "category")
                    MovementInputTextFieldView(
                        placeholderText: "Notes",
                        stickyText: "Notes",
                        text: $viewModel.movement.notes)
                    .formFieldError($viewModel.errors, "notes")
                }
                Section("Recommendations (Optional)") {
                    MovementInputTextFieldView(
                        placeholderText: "Warmup sets",
                        stickyText: "Warmup sets",
                        text: $viewModel.movement.recommended_warmup_sets)
                    .formFieldError($viewModel.errors, "recommended_warmup_sets")
                    MovementInputTextFieldView(
                        placeholderText: "Working sets",
                        stickyText: "Working sets",
                        text: $viewModel.movement.recommended_working_sets)
                    .formFieldError($viewModel.errors, "recommended_working_sets")
                    MovementInputTextFieldView(
                        placeholderText: "Rep range",
                        stickyText: "Rep range",
                        text: $viewModel.movement.recommended_rep_range)
                    .formFieldError($viewModel.errors, "recommended_rep_range")
                    MovementInputTextFieldView(
                        placeholderText: "RPE",
                        stickyText: "RPE",
                        text: $viewModel.movement.recommended_rpe)
                    .formFieldError($viewModel.errors, "recommended_rpe")
                    MovementInputIntFieldView(
                        placeholderText: "Rest time (in seconds)",
                        stickyText: "Rest seconds",
                        value: $viewModel.movement.recommended_rest_time)
                    .formFieldError($viewModel.errors, "recommended_rest_time")
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
                viewModel.movement = Movement(
                    name: "",
                    category: "",
                    notes: "",
                    recommended_warmup_sets: "",
                    recommended_working_sets: "",
                    recommended_rep_range: "",
                    recommended_rpe: "")
            }
            .interactiveDismissDisabled()
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
            movement: Movement(
                name: "",
                category: "",
                notes: "",
                recommended_warmup_sets: "",
                recommended_working_sets: "",
                recommended_rep_range: "",
                recommended_rpe: ""),
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

struct MovementInputIntFieldView: View {
    var placeholderText: String
    var stickyText: String
    @Binding var value: UInt16?

    var body: some View {
        HStack {
            TextField(placeholderText, value: $value, format: .number)
                .textFieldStyle(.plain)
            if value != nil {
                Text(stickyText)
                    .textCase(.uppercase)
                    .font(.caption)
                    .fontWeight(.semibold)
            }
        }
        .animation(.default, value: value)
    }
}
