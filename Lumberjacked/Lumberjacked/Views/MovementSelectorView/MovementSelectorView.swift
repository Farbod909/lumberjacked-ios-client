//
//  CreateWorkoutMovementSelectorView.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/30/25.
//

import SwiftUI

struct MovementSelectorView: View {
    @State var viewModel = ViewModel()
    @State var errors = LumberjackedClientErrors()
    @State var searchText = ""
    // Keeps track of the most recently added new movement,
    // if the user adds a new movement from within the selector view.
    @State var newlyAddedMovement: Movement?
    @Environment(\.dismiss) var dismiss
    var dismissAction: (() -> Void)? = nil
    
    var body: some View {
        List {
            FormErrors(errors: $errors)
            if !viewModel.selectedMovements.isEmpty {
                Section("Selected exercises") {
                    ForEach($viewModel.selectedMovements, id: \.self, editActions: .all) { $movement in
                        HStack {
                            Text(movement.name)
                            Spacer()
                            Image(systemName: "line.3.horizontal")
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
                .listSectionSpacing(.compact)
            } else {
                Text("\(Image(systemName: "info.circle")) Add at least one movement to your workout to start. You can easily add or remove movements during your workout.")
            }
            if viewModel.isLoading {
                ProgressView()
            } else {
                HStack {
                    TextField("Add a movement to this workout...", text: $searchText)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .keyboardType(.alphabet)
                }
                Section {
                    if !searchText.isEmpty {
                        Button {
                            Task {
                                if let newMovement = await viewModel.attemptQuickAddMovement(
                                    movementName: formattedSearchText,
                                    errors: $errors) {
                                    viewModel.selectedMovements.append(newMovement)
                                    searchText = ""
                                    await viewModel.attemptGetMovements(errors: $errors)
                                }
                            }
                        } label: {
                            VStack(alignment: .leading) {
                                Label("Quick Add \"\(formattedSearchText)\"", systemImage: "plus")
                                Text("Quick-added movements can be edited later.")
                                    .foregroundStyle(.gray)
                                    .font(.caption2)
                                    .padding(EdgeInsets(top: 1, leading: 0, bottom: 0, trailing: 0))
                            }
                        }
                        Button {
                            viewModel.showCreateMovementSheet = true
                        } label: {
                            VStack(alignment: .leading) {
                                Label("Create Movement: \"\(formattedSearchText)\"...", systemImage: "plus")
                            }
                        }
                    }
                }
                .listSectionSpacing(.compact)
                Section {
                    ForEach(searchResults, id: \.self) { movement in
                        Button(action: {
                            if self.viewModel.selectedMovements.map({ $0.id }).contains(movement.id) {
                                self.viewModel.selectedMovements.removeAll(where: { $0.id == movement.id })
                            } else {
                                self.viewModel.selectedMovements.append(movement)
                                searchText = ""
                            }
                        }) {
                            HStack {
                                Text("\(movement.name)")
                                Spacer()
                                Image(systemName: "checkmark")
                                    .opacity(self.viewModel.selectedMovements.map({ $0.id }).contains(movement.id) ? 1.0 : 0.0)
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
                .listSectionSpacing(.compact)
            }
        }
        .listStyle(.inset)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                if viewModel.workout != nil && viewModel.workout!.id != nil {
                    Button("Save") {
                        Task {
                            await viewModel.attemptEditWorkout(
                                errors: $errors, dismissAction: dismissAction ?? { dismiss() })
                        }
                    }
                } else {
                    Button("Start Workout") {
                        Task {
                            await viewModel.attemptCreateWorkout(
                                errors: $errors, dismissAction: dismissAction ?? { dismiss() })
                        }
                    }
                }
            }
        }
        .task {
            await viewModel.attemptGetMovements(errors: $errors)
        }
        .sheet(
            isPresented: $viewModel.showCreateMovementSheet,
            onDismiss: {
                Task {
                    if let newMovement = newlyAddedMovement {
                        viewModel.selectedMovements.append(newMovement)
                        newlyAddedMovement = nil
                        searchText = ""
                    }
                    await viewModel.attemptGetMovements(errors: $errors)
                }
            }
            ) {
                MovementInputView(
                    viewModel: MovementInputView.ViewModel(movement: Movement(
                        name: formattedSearchText,
                        category: "",
                        notes: "",
                        recommended_warmup_sets: "",
                        recommended_working_sets: "",
                        recommended_rep_range: "",
                        recommended_rpe: "")),
                    newlyAddedMovement: $newlyAddedMovement)
            }
        .animation(.default, value: viewModel.allMovements)
        .animation(.default, value: viewModel.selectedMovements)

    }
    
    var searchResults: [Movement] {
        if searchText.isEmpty {
            return []
        } else {
            return viewModel.allMovements.filter {
                $0.name.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    var formattedSearchText: String {
        return searchText.trimmingCharacters(in: [" "]) .capitalized
    }

}
