//
//  WorkoutTemplateEditorView.swift
//

import SwiftUI

struct WorkoutTemplateEditorView: View {
    @State var viewModel: ViewModel
    @State private var editMode = EditMode.active
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
                        ForEach(viewModel.selectedMovements, id: \.self) { movement in
                            Text(movement.name)
                        }
                        .onMove { viewModel.selectedMovements.move(fromOffsets: $0, toOffset: $1) }
                        .onDelete { viewModel.selectedMovements.remove(atOffsets: $0) }
                    }
                    .id(viewModel.selectedMovements.count)
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
            .environment(\.editMode, $editMode)
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
