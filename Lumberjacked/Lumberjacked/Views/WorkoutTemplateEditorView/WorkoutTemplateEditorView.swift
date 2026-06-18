//
//  WorkoutTemplateEditorView.swift
//  Lumberjacked
//

import SwiftUI

struct WorkoutTemplateEditorView: View {
    @State var viewModel: ViewModel
    let onSave: (WorkoutTemplate) -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("Template name", text: $viewModel.name)
                        .autocorrectionDisabled()
                }

                if !viewModel.selectedMovements.isEmpty {
                    Section("Movements") {
                        ForEach($viewModel.selectedMovements, id: \.self, editActions: .move) { $movement in
                            HStack {
                                Text(movement.name)
                                Spacer()
                                Image(systemName: "line.3.horizontal")
                                    .foregroundStyle(.tertiary)
                            }
                            .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        viewModel.selectedMovements.removeAll { $0.id == movement.id }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                }

                Section {
                    HStack {
                        TextField(
                            "Search movements...",
                            text: $viewModel.searchText
                        )
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .keyboardType(.alphabet)

                        if viewModel.isLoading(.movements) {
                            ProgressView()
                        }
                    }

                    ForEach(viewModel.searchResults, id: \.self) { movement in
                        let alreadyAdded = viewModel.selectedMovements.map(\.id).contains(movement.id)
                        Button {
                            guard !alreadyAdded else { return }
                            viewModel.selectedMovements.append(movement)
                            viewModel.searchText = ""
                        } label: {
                            HStack {
                                Text(movement.name)
                                Spacer()
                                if alreadyAdded {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .foregroundStyle(alreadyAdded ? .secondary : .primary)
                    }
                }
            }
            .navigationTitle(viewModel.isEditMode ? "Edit Template" : "New Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if viewModel.isLoading(.action) {
                        ProgressView()
                    } else {
                        Button("Save") {
                            Task {
                                await viewModel.save { saved in
                                    onSave(saved)
                                    dismiss()
                                }
                            }
                        }
                        .disabled(!viewModel.canSave)
                        .fontWeight(.semibold)
                    }
                }
            }
            .alert(item: $viewModel.alert)
            .task {
                await viewModel.attemptGetMovements()
            }
        }
    }
}

#if DEBUG
#Preview("Create") {
    WorkoutTemplateEditorView(
        viewModel: WorkoutTemplateEditorView.ViewModel(
            template: nil,
            templateAPI: MockWorkoutTemplateAPI(),
            movementAPI: MockMovementAPI()
        ),
        onSave: { _ in }
    )
}

#Preview("Edit") {
    WorkoutTemplateEditorView(
        viewModel: WorkoutTemplateEditorView.ViewModel(
            template: PreviewData.workoutTemplate_pushDay,
            templateAPI: MockWorkoutTemplateAPI(),
            movementAPI: MockMovementAPI()
        ),
        onSave: { _ in }
    )
}
#endif
