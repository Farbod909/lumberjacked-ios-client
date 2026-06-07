//
//  WorkoutDetailView-ViewModel.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/22/25.
//

import SwiftUI

extension WorkoutDetailView {
    @Observable
    class ViewModel {
        enum Destination: Identifiable, Hashable {
            case movementLogInput(MovementLog, Movement)
            var id: String {
                switch self {
                case .movementLogInput(let log, _): return "movementLogInput-\(log.id ?? 0)"
                }
            }
        }
        var destination: Destination?

        var workout: Workout
        var alert: AppAlert?

        var showDeleteConfirmationAlert = false
        var deleteActionLoading = false

        private let api: WorkoutAPIProtocol

        init(workout: Workout, api: WorkoutAPIProtocol = LiveWorkoutAPI()) {
            self.workout = workout
            self.api = api
        }

        func movementLogTapped(_ log: MovementLog, movement: Movement) {
            destination = .movementLogInput(log, movement)
        }

        func attemptDeleteWorkout() async -> Bool {
            guard let id = workout.id else { return false }
            deleteActionLoading = true
            do {
                try await api.deleteWorkout(id: id)
                deleteActionLoading = false
                return true
            } catch let error as RemoteNetworkingError {
                handleNetworkError(error)
            } catch {
                alert = AppAlert(title: "Error", message: error.localizedDescription)
            }
            deleteActionLoading = false
            return false
        }

        func attemptRefreshWorkout() async {
            guard let id = workout.id else { return }
            do {
                workout = try await api.getWorkout(workoutId: id)
            } catch let error as RemoteNetworkingError {
                handleNetworkError(error)
            } catch {
                alert = AppAlert(title: "Error", message: error.localizedDescription)
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
