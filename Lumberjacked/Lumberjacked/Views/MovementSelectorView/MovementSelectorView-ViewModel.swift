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
        var errors = LumberjackedClientErrors()

        private let workoutAPI: WorkoutAPIProtocol
        private let movementAPI: MovementAPIProtocol

        init(
            workout: Workout? = nil,
            selectedMovements: [Movement] = [],
            workoutAPI: WorkoutAPIProtocol = LiveWorkoutAPI(),
            movementAPI: MovementAPIProtocol = LiveMovementAPI()
        ) {
            self.workout = workout
            self.workoutAPI = workoutAPI
            self.movementAPI = movementAPI
            if !selectedMovements.isEmpty {
                self.selectedMovements = selectedMovements
            } else if let movements_details = workout?.movements_details {
                self.selectedMovements = movements_details
            } else {
                self.selectedMovements = []
            }
        }

        func attemptGetMovements() async {
            isLoading = true
            errors.messages = [:]
            do {
                let response = try await movementAPI.getMovements()
                allMovements = response.results
            } catch let error as RemoteNetworkingError {
                if let messages = error.messages {
                    errors.messages = messages
                } else {
                    errors.messages["detail"] = "Unknown error"
                }
            } catch {
                errors.messages["detail"] = "Unknown error"
            }
            isLoading = false
        }

        @MainActor
        func attemptCreateWorkout(dismissAction: () -> Void) async {
            isLoadingToolbarAction = true
            errors.messages = [:]
            do {
                _ = try await workoutAPI.createWorkout(
                    movements: selectedMovements.map { $0.id! })
                dismissAction()
            } catch let error as RemoteNetworkingError {
                if let messages = error.messages {
                    errors.messages = messages
                } else {
                    errors.messages["detail"] = "Unknown error"
                }
            } catch {
                errors.messages["detail"] = "Unknown error"
            }
            isLoadingToolbarAction = false
        }

        @MainActor
        func attemptEditWorkout(dismissAction: () -> Void) async {
            guard let workoutId = workout?.id else { return }
            isLoadingToolbarAction = true
            errors.messages = [:]
            do {
                _ = try await workoutAPI.updateWorkout(
                    workoutId: workoutId,
                    movements: selectedMovements.map { $0.id! })
                dismissAction()
            } catch let error as RemoteNetworkingError {
                if let messages = error.messages {
                    errors.messages = messages
                } else {
                    errors.messages["detail"] = "Unknown error"
                }
            } catch {
                errors.messages["detail"] = "Unknown error"
            }
            isLoadingToolbarAction = false
        }

        @MainActor
        func attemptQuickAddMovement(movementName: String) async -> Movement? {
            isLoadingToolbarAction = true
            errors.messages = [:]
            do {
                let movement = try await movementAPI.createMovement(
                    movement: Movement(
                        name: movementName,
                        category: "",
                        notes: "",
                        recommended_warmup_sets: "",
                        recommended_working_sets: "",
                        recommended_rep_range: "",
                        recommended_rpe: ""))
                return movement
            } catch let error as RemoteNetworkingError {
                if let messages = error.messages {
                    errors.messages = messages
                } else {
                    errors.messages["detail"] = "Unknown error"
                }
            } catch {
                errors.messages["detail"] = "Unknown error"
            }
            isLoadingToolbarAction = false
            return nil
        }
    }
}
