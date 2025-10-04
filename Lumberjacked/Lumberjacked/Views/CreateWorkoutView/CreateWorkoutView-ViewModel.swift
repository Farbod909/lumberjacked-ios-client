//
//  CreateWorkoutView-ViewModel.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/22/25.
//

import SwiftUI

extension CreateWorkoutView {
    @Observable
    class ViewModel {
        var templateWorkout: Workout?
        var isLoadingToolbarAction = false
        
        @MainActor
        func attemptCreateWorkout(errors: Binding<LumberjackedClientErrors>, dismissAction: () -> Void) async {
            guard let selectedMovements: [Movement] = self.templateWorkout?.movements_details else {
                return
            }
            
            isLoadingToolbarAction = true
            if let _ = await LumberjackedClient(errors: errors).createWorkout(
                movements: selectedMovements.map() { $0.id! }) {
                dismissAction()
            }
            isLoadingToolbarAction = false
        }
    }
}
