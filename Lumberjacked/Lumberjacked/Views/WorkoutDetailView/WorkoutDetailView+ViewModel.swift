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
        var workout: Workout
        var errors = LumberjackedClientErrors()

        var showDeleteConfirmationAlert = false
        var deleteActionLoading = false

        private let api: WorkoutAPIProtocol

        init(workout: Workout, api: WorkoutAPIProtocol = LiveWorkoutAPI()) {
            self.workout = workout
            self.api = api
        }

        func attemptDeleteWorkout() async -> Bool {
            guard let id = workout.id else { return false }
            deleteActionLoading = true
            errors.messages = [:]
            do {
                try await api.deleteWorkout(id: id)
                deleteActionLoading = false
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
            deleteActionLoading = false
            return false
        }

        func attemptRefreshWorkout() async {
            guard let id = workout.id else { return }
            errors.messages = [:]
            do {
                workout = try await api.getWorkout(workoutId: id)
            } catch let error as RemoteNetworkingError {
                if let messages = error.messages {
                    errors.messages = messages
                } else {
                    errors.messages["detail"] = "Unknown error"
                }
            } catch {
                errors.messages["detail"] = "Unknown error"
            }
        }
    }
}
