//
//  MovementInputView.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/22/25.
//

import SwiftUI

struct MovementInputView: View {
    @State var viewModel: ViewModel
    @State var errors = LumberjackedClientErrors()
    @Binding var newlyAddedMovement: Movement? // Binding to tell parent view about a new movement.
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    MovementInputTextFieldView(
                        placeholderText: "Movement name",
                        stickyText: "Name",
                        text: $viewModel.movement.name)
                    .formFieldError($errors, "name")
                    MovementInputTextFieldView(
                        placeholderText: "Category",
                        stickyText: "Category",
                        text: $viewModel.movement.category)
                    .formFieldError($errors, "category")
                    MovementInputTextFieldView(
                        placeholderText: "Notes",
                        stickyText: "Notes",
                        text: $viewModel.movement.notes)
                    .formFieldError($errors, "notes")
                }
                Section("Recommendations (Optional)") {
                    MovementInputTextFieldView(
                        placeholderText: "Warmup sets",
                        stickyText: "Warmup sets",
                        text: $viewModel.movement.recommended_warmup_sets)
                    .formFieldError($errors, "recommended_warmup_sets")
                    MovementInputTextFieldView(
                        placeholderText: "Working sets",
                        stickyText: "Working sets",
                        text: $viewModel.movement.recommended_working_sets)
                    .formFieldError($errors, "recommended_working_sets")
                    MovementInputTextFieldView(
                        placeholderText: "Rep range",
                        stickyText: "Rep range",
                        text: $viewModel.movement.recommended_rep_range)
                    .formFieldError($errors, "recommended_rep_range")
                    MovementInputTextFieldView(
                        placeholderText: "RPE",
                        stickyText: "RPE",
                        text: $viewModel.movement.recommended_rpe)
                    .formFieldError($errors, "recommended_rpe")
                    MovementInputIntFieldView(
                        placeholderText: "Rest time (in seconds)",
                        stickyText: "Rest seconds",
                        value: $viewModel.movement.recommended_rest_time)
                    .formFieldError($errors, "recommended_rest_time")
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
                                    errors: $errors, dismissAction: { dismiss() }) {
                                    newlyAddedMovement = movement
                                }
                            } else {
                                await viewModel.attemptUpdateMovement(
                                    errors: $errors, dismissAction: { dismiss() })
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
    
    var body: some View {
        HStack {
            TextField(placeholderText, text: $text)
                .textFieldStyle(.plain)
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
