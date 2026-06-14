//
//  MovementSelectorView-ViewModel.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/30/25.
//

import SwiftUI

extension MovementSelectorView {
    @Observable
    class ViewModel: LoadingTrackable {
        enum LoadingKey { case movements, action }
        var loadingKeys: Set<LoadingKey> = [.movements]

        var workout: Workout?
        var allMovements = [Movement]()
        var selectedMovements: [Movement]
        var showCreateMovementSheet = false
        var fieldErrors: [String: String] = [:]
        var alert: AppAlert?

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
            try? await withLoading(.movements) {
                self.fieldErrors = [:]
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
        func attemptCreateWorkout(dismissAction: () -> Void) async {
            try? await withLoading(.action) {
                self.fieldErrors = [:]
                do {
                    _ = try await self.workoutAPI.createWorkout(
                        movements: self.selectedMovements.map { $0.id! })
                    dismissAction()
                } catch let error as RemoteNetworkingError {
                    self.handleNetworkError(error)
                } catch {
                    self.alert = AppAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }

        @MainActor
        func attemptEditWorkout(dismissAction: () -> Void) async {
            guard let workoutId = workout?.id else { return }
            try? await withLoading(.action) {
                self.fieldErrors = [:]
                do {
                    _ = try await self.workoutAPI.updateWorkout(
                        workoutId: workoutId,
                        movements: self.selectedMovements.map { $0.id! })
                    dismissAction()
                } catch let error as RemoteNetworkingError {
                    self.handleNetworkError(error)
                } catch {
                    self.alert = AppAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }

        @MainActor
        func attemptQuickAddMovement(movementName: String) async -> Movement? {
            loadingKeys.insert(.action)
            defer { loadingKeys.remove(.action) }
            fieldErrors = [:]
            do {
                let movement = try await movementAPI.createMovement(
                    movement: Movement(name: movementName, notes: ""))
                return movement
            } catch let error as RemoteNetworkingError {
                handleNetworkError(error)
            } catch {
                alert = AppAlert(title: "Error", message: error.localizedDescription)
            }
            return nil
        }

        private func handleNetworkError(_ error: RemoteNetworkingError) {
            guard let messages = error.messages else {
                alert = AppAlert(title: "Error", message: "Unknown error")
                return
            }
            for (key, value) in messages {
                let message = extractString(from: value)
                if key == "detail" || key == "non_field_errors" {
                    alert = AppAlert(title: "Error", message: message)
                } else {
                    fieldErrors[key] = message
                }
            }
        }

        private func extractString(from value: Any) -> String {
            if let arr = value as? NSArray {
                return arr.compactMap { $0 as? String }.joined(separator: "\n")
            }
            if let str = value as? String { return str }
            return "Unknown error"
        }
    }
}
