//
//  MovementSelectorView-ViewModel.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/30/25.
//

import SwiftUI

extension MovementSelectorView {
    @Observable
    class ViewModel {
        var templateWorkout: Workout?
        var allMovements = [Movement]()
        var selectedMovements: [Movement]
        var isLoading = true
        var isLoadingToolbarAction = false
        
        init(templateWorkout: Workout? = nil) {
            self.templateWorkout = templateWorkout
            if let movements_details = templateWorkout?.movements_details {
                self.selectedMovements = movements_details
            } else {
                self.selectedMovements = []
            }
        }
        
        func attemptGetMovements(errors: Binding<LumberjackedClientErrors>) async {
            isLoading = true
            if let response = await LumberjackedClient(errors: errors).getMovements() {
                allMovements = response.results
            }
            isLoading = false
        }
        
        func attemptCreateWorkout(errors: Binding<LumberjackedClientErrors>, dismissAction: () -> Void) async {
            isLoadingToolbarAction = true
            if let _ = await LumberjackedClient(errors: errors).createWorkout(
                movements: selectedMovements.map() { $0.id! }) {
                dismissAction()
            }
            isLoadingToolbarAction = false
        }
    }
}
