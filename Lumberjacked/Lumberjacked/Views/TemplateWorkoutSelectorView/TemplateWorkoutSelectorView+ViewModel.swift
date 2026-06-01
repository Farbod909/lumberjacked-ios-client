//
//  TemplateWorkoutSelectorView-ViewModel.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/22/25.
//

import SwiftUI

extension TemplateWorkoutSelectorView {
    @Observable
    class ViewModel {
        var workouts = [Workout]()
        var isLoading = true
        var errors = LumberjackedClientErrors()

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
