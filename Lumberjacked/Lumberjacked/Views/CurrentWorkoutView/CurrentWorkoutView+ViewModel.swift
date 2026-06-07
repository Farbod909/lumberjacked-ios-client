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

        enum Destination: Identifiable, Hashable {
            case settings
            case editWorkout
            var id: String {
                switch self {
                case .settings: return "settings"
                case .editWorkout: return "editWorkout"
                }
            }
        }
        var destination: Destination?

        var currentWorkout: Workout?
        var showCreateWorkoutSheet = false
        var alert: AppAlert?

        var addMovementTextFieldFocused = false
        var showAddMovementOverlay = false

        var allMovements = [Movement]()
        var searchText = ""

        var placeholderWidth: CGFloat = 0

        private let workoutAPI: WorkoutAPIProtocol
        private let movementAPI: MovementAPIProtocol

        init(
            workoutAPI: WorkoutAPIProtocol = LiveWorkoutAPI(),
            movementAPI: MovementAPIProtocol = LiveMovementAPI()
        ) {
            self.workoutAPI = workoutAPI
            self.movementAPI = movementAPI
        }

        func settingsTapped() {
            destination = .settings
        }

        func editWorkoutTapped() {
            destination = .editWorkout
        }

        func attemptGetCurrentWorkout() async {
            try? await withLoading(.currentWorkout) {
                do {
                    self.currentWorkout = try await self.workoutAPI.getCurrentWorkout()
                } catch let error as RemoteNetworkingError {
                    // 404 means no active workout — not a true error
                    if error.statusCode == 404 {
                        self.currentWorkout = nil
                    } else {
                        self.handleNetworkError(error)
                    }
                } catch {
                    self.alert = AppAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }

        func attemptEndCurrentWorkout() async {
            guard let id = currentWorkout?.id else { return }
            try? await withLoading(.endWorkout) {
                do {
                    try await self.workoutAPI.endWorkout(id: id)
                    self.currentWorkout = nil
                } catch let error as RemoteNetworkingError {
                    self.handleNetworkError(error)
                } catch {
                    self.alert = AppAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }

        func attemptDeleteCurrentWorkout() async {
            guard let id = currentWorkout?.id else { return }
            try? await withLoading(.deleteWorkout) {
                do {
                    try await self.workoutAPI.deleteWorkout(id: id)
                    self.currentWorkout = nil
                } catch let error as RemoteNetworkingError {
                    self.handleNetworkError(error)
                } catch {
                    self.alert = AppAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }

        func attemptGetMovements() async {
            try? await withLoading(.movements) {
                do {
                    let response = try await self.movementAPI.getMovements()
                    self.allMovements = response.results
                } catch let error as RemoteNetworkingError {
                    self.handleNetworkError(error)
                } catch {
                    self.alert = AppAlert(title: "Error", message: error.localizedDescription)
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
                do {
                    _ = try await self.workoutAPI.createWorkout(movements: [movementId])
                } catch let error as RemoteNetworkingError {
                    self.handleNetworkError(error)
                } catch {
                    self.alert = AppAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }

        @MainActor
        func attemptQuickAddMovement(movementName: String) async -> Movement? {
            loadingKeys.insert(.addMovement)
            defer { loadingKeys.remove(.addMovement) }
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
                handleNetworkError(error)
            } catch {
                alert = AppAlert(title: "Error", message: error.localizedDescription)
            }
            return nil
        }

        @MainActor
        func attemptAddMovementToCurrentWorkout(addMovementId: UInt64, dismissAction: () -> Void) async {
            if let currentWorkoutMovements = currentWorkout?.movements_details {
                var newMovementsList = currentWorkoutMovements.map { $0.id! }
                newMovementsList.append(addMovementId)
                try? await withLoading(.addMovement) {
                    do {
                        _ = try await self.workoutAPI.updateWorkout(
                            workoutId: self.currentWorkout!.id!,
                            movements: newMovementsList)
                        dismissAction()
                    } catch let error as RemoteNetworkingError {
                        self.handleNetworkError(error)
                    } catch {
                        self.alert = AppAlert(title: "Error", message: error.localizedDescription)
                    }
                }
            }
        }

        private func handleNetworkError(_ error: RemoteNetworkingError) {
            guard let messages = error.messages else {
                alert = AppAlert(title: "Error", message: "Unknown error")
                return
            }
            let msg = messages.values.compactMap { value -> String? in
                if let arr = value as? NSArray {
                    return arr.compactMap { $0 as? String }.joined(separator: "\n")
                }
                return value as? String
            }.joined(separator: "\n")
            alert = AppAlert(title: "Error", message: msg.isEmpty ? "Unknown error" : msg)
        }
    }
}
