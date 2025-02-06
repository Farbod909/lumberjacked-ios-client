//
//  MovementCatalogView-ViewModel.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/21/25.
//

import SwiftUI

extension MovementCatalogView {
    @Observable
    class ViewModel {
        var movements = [Movement]()
        var isLoading = true
        var searchText = ""
        
        func attemptGetMovements(errors: Binding<LumberjackedClientErrors>) async {
            isLoading = true
            if let response = await LumberjackedClient(errors: errors).getMovements() {
                movements = response.results
            }
            isLoading = false
        }
        
        var filteredMovements: [Movement] {
            if searchText.isEmpty {
                return movements
            } else {
                return movements.filter { $0.name!.contains(searchText) }
            }
        }
    }
}
