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
        var workout: Workout?
        var allMovements = [Movement]()
        var selectedMovements: [Movement]
        var isLoading = true
        var isLoadingToolbarAction = false
        var showCreateMovementSheet = false
        
        init(workout: Workout? = nil) {
            self.workout = workout
            if let movements_details = workout?.movements_details {
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
        
        @MainActor
        func attemptCreateWorkout(errors: Binding<LumberjackedClientErrors>, dismissAction: () -> Void) async {
            isLoadingToolbarAction = true
            if let _ = await LumberjackedClient(errors: errors).createWorkout(
                movements: selectedMovements.map() { $0.id! }) {
                dismissAction()
            }
            isLoadingToolbarAction = false
        }
        
        @MainActor
        func attemptEditWorkout(errors: Binding<LumberjackedClientErrors>, dismissAction: () -> Void) async {
            isLoadingToolbarAction = true
            if let _ = await LumberjackedClient(errors: errors).updateWorkout(
                workoutId: (workout?.id)!,
                movements: selectedMovements.map() { $0.id! }) {
                dismissAction()
            }
            isLoadingToolbarAction = false
        }
        
        @MainActor
        func attemptQuickAddMovement(movementName: String, errors: Binding<LumberjackedClientErrors>) async -> Movement? {
            isLoadingToolbarAction = true
            if let movement = await LumberjackedClient(errors: errors)
                .createMovement(
                    movement: Movement.init(
                        name: movementName,
                        category: "",
                        notes: "",
                        recommended_warmup_sets: "",
                        recommended_working_sets: "",
                        recommended_rep_range: "",
                        recommended_rpe: "")) {
                return movement
            }
            isLoadingToolbarAction = false
            return nil
        }


    }
}
