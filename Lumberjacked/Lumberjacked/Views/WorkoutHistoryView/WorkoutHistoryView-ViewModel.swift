//
//  WorkoutHistoryView-ViewModel.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/21/25.
//

import SwiftUI

extension WorkoutHistoryView {
    @Observable
    class ViewModel {
        var isLoading = true
        var workouts = [Workout]()
        var errors = LumberjackedClientErrors()

        var pastWorkouts: [Workout] {
            workouts.filter { $0.end_timestamp != nil }
        }

        private let api: WorkoutAPIProtocol

        init(api: WorkoutAPIProtocol = LiveWorkoutAPI()) {
            self.api = api
        }

        func attemptGetWorkouts() async {
            isLoading = true
            errors.messages = [:]
            do {
                let response = try await api.getWorkouts()
                workouts = response.results
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
    }
}
