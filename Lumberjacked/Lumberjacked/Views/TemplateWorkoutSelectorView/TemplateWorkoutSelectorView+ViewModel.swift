//
//  TemplateWorkoutSelectorView-ViewModel.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/22/25.
//

import SwiftUI

extension TemplateWorkoutSelectorView {
    @Observable
    class ViewModel: LoadingTrackable {
        enum LoadingKey { case load }
        var loadingKeys: Set<LoadingKey> = [.load]

        var workouts = [Workout]()
        var alert: AppAlert?

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
            alert = AppAlert(title: "Error", message: error.localizedDescription)
        }
    }
}
