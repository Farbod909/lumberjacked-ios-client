//
//  CatalogView.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/21/25.
//

import SwiftUI

struct MovementCatalogView: View {
    @State var viewModel: ViewModel

    init(viewModel: ViewModel = ViewModel()) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.filteredMovements, id: \.self) { movement in
                    Button {
                        viewModel.movementTapped(movement)
                    } label: {
                        Text(movement.name)
                    }
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(.inset)
            .scrollContentBackground(.hidden)
            .background(Color.brandBackground.ignoresSafeArea())
            .navigationTitle("Movement Catalog")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await viewModel.attemptGetMovements()
            }
            .navigationDestination(item: $viewModel.destination) { dest in
                switch dest {
                case .movementDetail(let movement):
                    MovementDetailView(viewModel: MovementDetailView.ViewModel(movement: movement))
                }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewModel.showCreateMovementSheet = true
                    } label: {
                        Label("New movement", systemImage: "plus")
                    }
                }
            }
            .sheet(
                isPresented: $viewModel.showCreateMovementSheet,
                onDismiss: {
                    Task {
                        await viewModel.attemptGetMovements()
                    }
                }
            ) {
                MovementInputView(
                    viewModel: MovementInputView.ViewModel(movement: Movement(
                        name: "",
                        category: "",
                        notes: "",
                        recommended_warmup_sets: "",
                        recommended_working_sets: "",
                        recommended_rep_range: "",
                        recommended_rpe: "")),
                    newlyAddedMovement: .constant(nil))
            }
        }
        .searchable(text: $viewModel.searchText)
        .autocorrectionDisabled()
        .textInputAutocapitalization(.never)
    }
}

#if DEBUG
#Preview("All Movements") {
    MovementCatalogView(viewModel: MovementCatalogView.ViewModel(api: MockMovementAPI()))
}

#Preview("Filtered") {
    let vm = MovementCatalogView.ViewModel(api: MockMovementAPI())
    vm.searchText = "bar"
    return MovementCatalogView(viewModel: vm)
}
#endif
