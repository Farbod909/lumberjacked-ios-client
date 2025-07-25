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
    
    let dismissAction: () -> Void
    
    var body: some View {
        List {
            if !viewModel.selectedMovements.isEmpty {
                Section("Selected exercises") {
                    ForEach($viewModel.selectedMovements, id: \.self, editActions: .move) { $movement in
                        HStack {
                            Text(movement.name)
                            Spacer()
                            Image(systemName: "line.3.horizontal")
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
                .listSectionSpacing(.default)
            }
            if viewModel.isLoading {
                ProgressView()
            } else {
                Section {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                        TextField("Search exercises", text: $searchText)
                    }
                }
                .listRowBackground(Color.init(uiColor: .systemGray5))
                Section {
                    ForEach(searchResults, id: \.self) { movement in
                        Button(action: {
                            withAnimation {
                                if self.viewModel.selectedMovements.map({ $0.id }).contains(movement.id) {
                                    self.viewModel.selectedMovements.removeAll(where: { $0.id == movement.id })
                                } else {
                                    self.viewModel.selectedMovements.append(movement)
                                }
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
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Start Workout") {
                    Task {
                        await viewModel.attemptCreateWorkout(errors: $errors, dismissAction: dismissAction)
                    }
                }
            }
        }
        .task {
            await viewModel.attemptGetMovements(errors: $errors)
        }
    }
    
    var searchResults: [Movement] {
        if searchText.isEmpty {
            return viewModel.allMovements
        } else {
            return viewModel.allMovements.filter { $0.name.contains(searchText) }
        }
    }

}

#Preview {
    MovementSelectorView(dismissAction: {})
}
