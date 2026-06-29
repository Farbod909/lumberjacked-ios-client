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
                if !viewModel.isLoading(.load) && !viewModel.movements.isEmpty {
                    searchRow
                    if viewModel.filteredMovements.isEmpty {
                        noSearchResultsRow
                    } else {
                        ForEach(viewModel.filteredMovements, id: \.self) { movement in
                            Button {
                                viewModel.movementTapped(movement)
                            } label: {
                                movementRow(movement)
                            }
                            .listRowBackground(Color.clear)
                        }
                    }
                }
            }
            .overlay {
                if viewModel.isLoading(.load) {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.movements.isEmpty {
                    emptyState
                }
            }
            .listStyle(.inset)
            .scrollContentBackground(.hidden)
            .scrollDismissesKeyboard(.immediately)
            .refreshable {
                await viewModel.attemptRefresh()
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
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Menu("Sort By") {
                            ForEach(MovementCatalogView.ViewModel.SortOrder.allCases, id: \.self) { order in
                                Button {
                                    viewModel.sortOrder = order
                                } label: {
                                    if viewModel.sortOrder == order {
                                        Label(order.rawValue, systemImage: "checkmark")
                                    } else {
                                        Text(order.rawValue)
                                    }
                                }
                            }
                        }
                        Menu("Filter") {
                            Button("Body Part") {
                                viewModel.showBodyPartFilterSheet = true
                            }
                            Button("Resistance Type") {
                                viewModel.showResistanceTypeFilterSheet = true
                            }
                        }
                        if viewModel.isFiltered {
                            Divider()
                            Button(role: .destructive) {
                                viewModel.resetFilters()
                            } label: {
                                Label("Reset Filters", systemImage: "xmark.circle")
                            }
                        }
                    } label: {
                        Image(systemName: viewModel.isFiltered ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
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
            .sheet(isPresented: $viewModel.showBodyPartFilterSheet) {
                BodyPartFilterSheet(selectedBodyParts: $viewModel.selectedBodyParts)
            }
            .sheet(isPresented: $viewModel.showResistanceTypeFilterSheet) {
                ResistanceTypeFilterSheet(selectedResistanceTypes: $viewModel.selectedResistanceTypes)
            }
        }
    }

    @ViewBuilder
    private func movementRow(_ movement: Movement) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(movement.name)
                .fontWeight(.medium)
            let bp = movement.body_part.flatMap { BodyPart(rawValue: $0) }
            let rt = movement.resistance_type.flatMap { ResistanceType(rawValue: $0) }
            if bp != nil || rt != nil {
                HStack {
                    if let bp {
                        Text(bp.displayName)
                    }
                    Spacer()
                    if let rt {
                        Text(rt.displayName)
                    }
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
        }
    }

    private var searchRow: some View {
        SearchBar(placeholder: "Search movements", text: $viewModel.searchText)
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 14, leading: 16, bottom: 10, trailing: 16))
    }

    private var noSearchResultsRow: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text(viewModel.searchText.isEmpty ? "No results" : "No results for \"\(viewModel.searchText)\"")
                .font(.headline)
            if !viewModel.searchText.isEmpty {
                Button("Clear Search") {
                    viewModel.searchText = ""
                }
                .font(.subheadline)
            }
            if viewModel.isFiltered {
                Button("Clear Filters") {
                    viewModel.resetFilters()
                }
                .font(.subheadline)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
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
