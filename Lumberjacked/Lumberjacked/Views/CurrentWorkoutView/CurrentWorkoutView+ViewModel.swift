//
//  CurrentWorkout-ViewModel.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/21/25.
//

import SwiftUI

extension CurrentWorkoutView {
    @Observable
    class ViewModel: LoadingTrackable {
        enum LoadingKey { case currentWorkout, movements, addMovement, endWorkout, deleteWorkout }
        var loadingKeys: Set<LoadingKey> = [.currentWorkout, .movements]

        var currentWorkout: Workout?
        var showCreateWorkoutSheet = false
        var showCancelConfirmationAlert = false
        var showFinishWorkoutConfirmationAlert = false

        var addMovementTextFieldFocused = false
        var showAddMovementOverlay = false

        var allMovements = [Movement]()
        var searchText = ""

        var placeholderWidth: CGFloat = 0
        var errors = LumberjackedClientErrors()

        private let workoutAPI: WorkoutAPIProtocol
        private let movementAPI: MovementAPIProtocol

        init(
            workoutAPI: WorkoutAPIProtocol = LiveWorkoutAPI(),
            movementAPI: MovementAPIProtocol = LiveMovementAPI()
        ) {
            self.workoutAPI = workoutAPI
            self.movementAPI = movementAPI
        }

        func attemptGetCurrentWorkout() async {
            try? await withLoading(.currentWorkout) {
                self.errors.messages = [:]
                do {
                    self.currentWorkout = try await self.workoutAPI.getCurrentWorkout()
                } catch let error as RemoteNetworkingError {
                    // 404 means no active workout — not a true error
                    if error.statusCode == 404 {
                        self.currentWorkout = nil
                    } else if let messages = error.messages {
                        self.errors.messages = messages
                    } else {
                        self.errors.messages["detail"] = "Unknown error"
                    }
                } catch {
                    self.errors.messages["detail"] = "Unknown error"
                }
            }
        }

        func attemptEndCurrentWorkout() async {
            guard let id = currentWorkout?.id else { return }
            try? await withLoading(.endWorkout) {
                self.errors.messages = [:]
                do {
                    try await self.workoutAPI.endWorkout(id: id)
                    self.currentWorkout = nil
                } catch let error as RemoteNetworkingError {
                    if let messages = error.messages {
                        self.errors.messages = messages
                    } else {
                        self.errors.messages["detail"] = "Unknown error"
                    }
                } catch {
                    self.errors.messages["detail"] = "Unknown error"
                }
            }
        }

        func attemptDeleteCurrentWorkout() async {
            guard let id = currentWorkout?.id else { return }
            try? await withLoading(.deleteWorkout) {
                self.errors.messages = [:]
                do {
                    try await self.workoutAPI.deleteWorkout(id: id)
                    self.currentWorkout = nil
                } catch let error as RemoteNetworkingError {
                    if let messages = error.messages {
                        self.errors.messages = messages
                    } else {
                        self.errors.messages["detail"] = "Unknown error"
                    }
                } catch {
                    self.errors.messages["detail"] = "Unknown error"
                }
            }
        }

        func attemptGetMovements() async {
            try? await withLoading(.movements) {
                self.errors.messages = [:]
                do {
                    let response = try await self.movementAPI.getMovements()
                    self.allMovements = response.results
                } catch let error as RemoteNetworkingError {
                    if let messages = error.messages {
                        self.errors.messages = messages
                    } else {
                        self.errors.messages["detail"] = "Unknown error"
                    }
                } catch {
                    self.errors.messages["detail"] = "Unknown error"
                }
            }
        }

        @MainActor
        func addMovementToCurrentWorkout(movementId: UInt64) async {
            if let movementIds = self.currentWorkout?.movements_details?.map({ $0.id }),
               !movementIds.contains(movementId) {
                await attemptAddMovementToCurrentWorkout(addMovementId: movementId) { }
            }
        }

        @MainActor
        func createWorkoutWithInitialMovement(movementId: UInt64) async {
            try? await withLoading(.addMovement) {
                self.errors.messages = [:]
                do {
                    _ = try await self.workoutAPI.createWorkout(movements: [movementId])
                } catch let error as RemoteNetworkingError {
                    if let messages = error.messages {
                        self.errors.messages = messages
                    } else {
                        self.errors.messages["detail"] = "Unknown error"
                    }
                } catch {
                    self.errors.messages["detail"] = "Unknown error"
                }
            }
        }

        @MainActor
        func attemptQuickAddMovement(movementName: String) async -> Movement? {
            loadingKeys.insert(.addMovement)
            defer { loadingKeys.remove(.addMovement) }
            errors.messages = [:]
            do {
                return try await movementAPI.createMovement(
                    movement: Movement(
                        name: movementName,
                        category: "",
                        notes: "",
                        recommended_warmup_sets: "",
                        recommended_working_sets: "",
                        recommended_rep_range: "",
                        recommended_rpe: ""))
            } catch let error as RemoteNetworkingError {
                if let messages = error.messages {
                    errors.messages = messages
                } else {
                    errors.messages["detail"] = "Unknown error"
                }
            } catch {
                errors.messages["detail"] = "Unknown error"
            }
            return nil
        }

        @MainActor
        func attemptAddMovementToCurrentWorkout(addMovementId: UInt64, dismissAction: () -> Void) async {
            if let currentWorkoutMovements = currentWorkout?.movements_details {
                var newMovementsList = currentWorkoutMovements.map { $0.id! }
                newMovementsList.append(addMovementId)
                try? await withLoading(.addMovement) {
                    self.errors.messages = [:]
                    do {
                        _ = try await self.workoutAPI.updateWorkout(
                            workoutId: self.currentWorkout!.id!,
                            movements: newMovementsList)
                        dismissAction()
                    } catch let error as RemoteNetworkingError {
                        if let messages = error.messages {
                            self.errors.messages = messages
                        } else {
                            self.errors.messages["detail"] = "Unknown error"
                        }
                    } catch {
                        self.errors.messages["detail"] = "Unknown error"
                    }
                }
            }
        }
    }
}
