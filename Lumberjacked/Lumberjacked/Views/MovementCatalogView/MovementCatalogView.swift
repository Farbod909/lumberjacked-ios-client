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
            Group {
                if viewModel.isLoading(.load) {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.movements.isEmpty {
                    emptyState
                } else if viewModel.filteredMovements.isEmpty {
                    noSearchResults
                } else {
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
                }
            }
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
                    viewModel: MovementInputView.ViewModel(movement: Movement(name: "", notes: "")),
                    newlyAddedMovement: .constant(nil))
            }
        }
        .searchable(text: $viewModel.searchText)
        .autocorrectionDisabled()
        .textInputAutocapitalization(.never)
    }
    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "dumbbell")
                .font(.system(size: 52))
                .foregroundStyle(.secondary)
            Text("No movements yet")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Add your first movement to start\ntracking your workouts.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button {
                viewModel.showCreateMovementSheet = true
            } label: {
                Label("Add Movement", systemImage: "plus")
                    .font(.headline)
                    .padding(.horizontal, 8)
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 4)
            Spacer()
            Spacer()
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity)
    }

    private var noSearchResults: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text("No results for \"\(viewModel.searchText)\"")
                .font(.headline)
            Button("Clear Search") {
                viewModel.searchText = ""
            }
            .font(.subheadline)
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity)
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

#Preview("Empty Catalog") {
    let vm = MovementCatalogView.ViewModel(api: MockMovementAPI())
    vm.loadingKeys = []
    vm.movements = []
    return MovementCatalogView(viewModel: vm)
}

#Preview("No Search Results") {
    let vm = MovementCatalogView.ViewModel(api: MockMovementAPI())
    vm.loadingKeys = []
    vm.movements = PreviewData.movements
    vm.searchText = "zzz"
    return MovementCatalogView(viewModel: vm)
}
#endif
