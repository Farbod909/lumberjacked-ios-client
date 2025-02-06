//
//  CatalogView.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/21/25.
//

import SwiftUI

struct MovementCatalogView: View {
    @State var viewModel = ViewModel()
    @State var errors = LumberjackedClientErrors()

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.filteredMovements, id: \.self) { movement in
                    Text(movement.name!)
                }
            }
            .task {
                await viewModel.attemptGetMovements(errors: $errors)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        // New movement
                    } label: {
                        Label("New movement", systemImage: "plus")
                    }
                }
            }
        }
        .searchable(text: $viewModel.searchText)
    }
}

#Preview {
    MovementCatalogView()
}
