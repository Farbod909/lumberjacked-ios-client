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
        var alert: AppAlert?

        var pastWorkouts: [Workout] {
            workouts.filter { $0.end_timestamp != nil }
        }

        private let api: WorkoutAPIProtocol

        init(api: WorkoutAPIProtocol = LiveWorkoutAPI()) {
            self.api = api
        }

        func attemptGetWorkouts() async {
            try? await withLoading(.load) {
                do {
                    let response = try await self.api.getWorkouts()
                    self.workouts = response.results
                } catch let error as RemoteNetworkingError {
                    self.handleNetworkError(error)
                } catch {
                    self.alert = AppAlert(title: "Error", message: error.localizedDescription)
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
