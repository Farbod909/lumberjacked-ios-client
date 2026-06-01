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
        var errors = LumberjackedClientErrors()

        private let api: MovementLogAPIProtocol

        init(
            movementLog: MovementLog,
            movement: Movement,
            workout: Workout?,
            api: MovementLogAPIProtocol = LiveMovementLogAPI()
        ) {
            self.movementLog = movementLog
            self.movement = movement
            self.workout = workout
            self.api = api
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
        func attemptDeleteLog(dismissAction: () -> Void) async {
            guard let movementLogId = movementLog.id else {
                print("No Movement ID")
                return
            }
            toolbarActionLoading = true
            errors.messages = [:]
            do {
                try await api.deleteLog(movementLogId: movementLogId)
                toolbarActionLoading = false
                dismissAction()
            } catch let error as RemoteNetworkingError {
                if let messages = error.messages {
                    errors.messages = messages
                } else {
                    errors.messages["detail"] = "Unknown error"
                }
                toolbarActionLoading = false
            } catch {
                errors.messages["detail"] = "Unknown error"
                toolbarActionLoading = false
            }
        }

        @MainActor
        func formSubmit(dismissAction: () -> Void) async {
            toolbarActionLoading = true
            let success: Bool
            if movementLog.id == nil {
                success = await attemptSaveNewLog()
            } else {
                success = await attemptUpdateLog()
            }
            toolbarActionLoading = false
            if success {
                dismissAction()
            }
        }

        func attemptUpdateLog() async -> Bool {
            guard let movementLogId = movementLog.id else {
                print("No Movement ID")
                return false
            }
            guard let movementLogInput = movementLogInput else {
                print("Input cannot be unwrapped")
                return false
            }
            errors.messages = [:]
            do {
                _ = try await api.updateLog(movementLogId: movementLogId, movementLog: movementLogInput)
                return true
            } catch let error as RemoteNetworkingError {
                if let messages = error.messages {
                    errors.messages = messages
                } else {
                    errors.messages["detail"] = "Unknown error"
                }
            } catch {
                errors.messages["detail"] = "Unknown error"
            }
            return false
        }

        func attemptSaveNewLog() async -> Bool {
            guard let movementLogInput = movementLogInput else {
                print("Input cannot be unwrapped")
                return false
            }
            errors.messages = [:]
            do {
                _ = try await api.createLog(movementLog: movementLogInput)
                return true
            } catch let error as RemoteNetworkingError {
                if let messages = error.messages {
                    errors.messages = messages
                } else {
                    errors.messages["detail"] = "Unknown error"
                }
            } catch {
                errors.messages["detail"] = "Unknown error"
            }
            return false
        }
    }
}
