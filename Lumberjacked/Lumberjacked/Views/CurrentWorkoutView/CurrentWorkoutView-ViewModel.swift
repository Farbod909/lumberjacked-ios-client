//
//  CurrentWorkout-ViewModel.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/21/25.
//

import SwiftUI

extension CurrentWorkoutView {
    @Observable
    class ViewModel {
        var currentWorkout: Workout?
        var isLoadingCurrentWorkout = true
        var showCreateWorkoutSheet = false
        var showCancelConfirmationAlert = false
        var showFinishWorkoutConfirmationAlert = false
        
        var addMovementTextFieldFocused = false
        var showAddMovementOverlay = false
        
        var isLoadingMovements = true
        var allMovements = [Movement]()
        var searchText = ""
        
        var placeholderWidth: CGFloat = 0

        func attemptGetCurrentWorkout(errors: Binding<LumberjackedClientErrors>) async {
            if let response = await LumberjackedClient(errors: errors).getCurrentWorkout() {
                currentWorkout = response
            }
        }
        
        func attemptEndCurrentWorkout(errors: Binding<LumberjackedClientErrors>) async {
            guard let currentWorkout = currentWorkout else {
                return
            }
            if let id = currentWorkout.id {
                if await LumberjackedClient(errors: errors).endWorkout(id: id) {
                    self.currentWorkout = nil
                }
            }
        }
        
        func attemptDeleteCurrentWorkout(errors: Binding<LumberjackedClientErrors>) async {
            guard let currentWorkout = currentWorkout else {
                return
            }
            if let id = currentWorkout.id {
                if await LumberjackedClient(errors: errors).deleteWorkout(id: id) {
                    self.currentWorkout = nil
                }
            }
        }
        
        func attemptGetMovements(errors: Binding<LumberjackedClientErrors>) async {
            if let response = await LumberjackedClient(errors: errors).getMovements() {
                allMovements = response.results
            }
        }
        
        @MainActor
        func addMovementToCurrentWorkout(errors: Binding<LumberjackedClientErrors>, movementId: UInt64) async {
            if let movementIds = self.currentWorkout?.movements_details?.map({ $0.id }),
               !movementIds.contains(movementId) {
                await attemptAddMovementToCurrentWorkout(addMovementId: movementId, errors: errors) { }
            }

        }
        
        @MainActor
        func createWorkoutWithInitialMovement(errors: Binding<LumberjackedClientErrors>, movementId: UInt64) async {
            if let _ = await LumberjackedClient(errors: errors).createWorkout(
                movements: [movementId]) { }
        }
        
        @MainActor
        func attemptQuickAddMovement(movementName: String, errors: Binding<LumberjackedClientErrors>) async -> Movement? {
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
            return nil
        }
        
        @MainActor
        func attemptAddMovementToCurrentWorkout(addMovementId: UInt64, errors: Binding<LumberjackedClientErrors>, dismissAction: () -> Void) async {
            if let currentWorkoutMovements = currentWorkout?.movements_details {
                var newMovementsList = currentWorkoutMovements.map() { $0.id! }
                newMovementsList.append(addMovementId)
                if let _ = await LumberjackedClient(errors: errors).updateWorkout(
                    workoutId: (currentWorkout?.id)!,
                    movements: newMovementsList) {
                    dismissAction()
                }
            }
        }


    }
}
