//
//  WorkoutHistoryView-ViewModel.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/21/25.
//

import SwiftUI

extension WorkoutHistoryView {
    @Observable
    class ViewModel: LoadingTrackable {
        enum LoadingKey { case load }
        var loadingKeys: Set<LoadingKey> = [.load]

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
            try? await withLoading(.load) {
                self.errors.messages = [:]
                do {
                    let response = try await self.api.getWorkouts()
                    self.workouts = response.results
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
