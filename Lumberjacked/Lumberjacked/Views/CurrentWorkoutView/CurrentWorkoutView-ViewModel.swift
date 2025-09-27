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
        var isLoading = true
        var showCreateWorkoutSheet = false
        var showCancelConfirmationAlert = false
        
        var addMovementText = ""
        var addMovementTextFieldFocused = false
        var showAddMovementOverlay = false
        
        var placeholderWidth: CGFloat = 0

        func attemptGetCurrentWorkout(errors: Binding<LumberjackedClientErrors>) async {
            isLoading = true
            if let response = await LumberjackedClient(errors: errors).getCurrentWorkout() {
                currentWorkout = response
            }
            isLoading = false
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
    }
}
