//
//  MovementLogInputView-ViewModel.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/22/25.
//

import SwiftUI

extension MovementLogInputView {
    @Observable
    class ViewModel {
        var movement: Movement
        var movementLog: MovementLog
        var workout: Workout?
        
        var selectedInputStyle = "Equal Sets"
        let inputStyles = ["Equal Sets", "Custom Sets"]

        var equalSetsMovementLogInput: EqualSetsMovementLogInput
        var customSetsMovementLogInput: CustomSetsMovementLogInput
        
        var movementLogInput: MovementLog? {
            var result = movementLog
            
            // We do not explicitly set these values in the client.
            result.for_current_workout = nil
            result.timestamp = nil
            
            if selectedInputStyle == "Equal Sets" {
                result.reps = Array(
                    repeating: equalSetsMovementLogInput.reps ?? 0,
                    count: Int(equalSetsMovementLogInput.sets ?? 0))
                result.loads = Array(
                    repeating: equalSetsMovementLogInput.load ?? 0,
                    count: Int(equalSetsMovementLogInput.sets ?? 0))
            } else if selectedInputStyle == "Custom Sets" {
                result.reps = customSetsMovementLogInput.reps
                result.loads = customSetsMovementLogInput.loads
            } else {
                return nil
            }
            if let workout = workout {
                result.workout = workout.id
            }
            result.movement = movement.id
            return result
        }
        
        var toolbarActionLoading = false
        
        init(
            movementLog: MovementLog,
            movement: Movement,
            workout: Workout?
        ) {
            self.movementLog = movementLog
            self.movement = movement
            self.workout = workout
            self.equalSetsMovementLogInput = .init(movementLog: movementLog)
            self.customSetsMovementLogInput = .init(movementLog: movementLog)
        }
        
        func canSave() -> Bool {
            if selectedInputStyle == "Custom Sets" {
                return false
            } else if selectedInputStyle == "Equal Sets" {
                
                if let sets = equalSetsMovementLogInput.sets,
                   let reps = equalSetsMovementLogInput.reps,
                   equalSetsMovementLogInput.load != nil {
                    return sets > 0 && reps > 0
                }
                return false
            }
            return false
        }
                
        @MainActor
        func attemptDeleteLog(errors: Binding<LumberjackedClientErrors>, dismissAction: () -> Void) async {
            guard let movementLogId = movementLog.id else {
                print("No Movement ID")
                return
            }
            toolbarActionLoading = true
            let success = await LumberjackedClient(errors: errors)
                .deleteLog(movementLogId: movementLogId)
            toolbarActionLoading = false
            if success {
                dismissAction()
            }

        }
        
        @MainActor
        func formSubmit(errors: Binding<LumberjackedClientErrors>, dismissAction: () -> Void) async {
            toolbarActionLoading = true
            let success: Bool
            if movementLog.id == nil {
                success = await attemptSaveNewLog(errors: errors)
            } else {
                success = await attemptUpdateLog(errors: errors)
            }
            toolbarActionLoading = false
            if success {
                dismissAction()
            }
        }
        
        func attemptUpdateLog(errors: Binding<LumberjackedClientErrors>) async -> Bool {
            guard let movementLogId = movementLog.id else {
                print("No Movement ID")
                return false
            }
            guard let movementLogInput = movementLogInput else {
                print("Input cannot be unwrapped")
                return false
            }
            print("AAAAAAA")
            print(movementLogId)
            print(movementLogInput)
            if let _ = await LumberjackedClient(errors: errors)
                .updateLog(movementLogId: movementLogId, movementLog: movementLogInput) {
                return true
            }
            return false
        }
        
        func attemptSaveNewLog(errors: Binding<LumberjackedClientErrors>) async -> Bool {
            guard let movementLogInput = movementLogInput else {
                print("Input cannot be unwrapped")
                return false
            }
            if let _ = await LumberjackedClient(errors: errors)
                .createLog(movementLog: movementLogInput) {
                return true
            }
            return false
        }

    }
}
