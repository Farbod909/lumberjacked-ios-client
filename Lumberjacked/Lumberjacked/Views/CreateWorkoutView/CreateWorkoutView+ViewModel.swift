//
//  CreateWorkoutView-ViewModel.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/22/25.
//

import SwiftUI

extension CreateWorkoutView {
    @Observable
    class ViewModel: LoadingTrackable {
        enum LoadingKey { case action }
        var loadingKeys: Set<LoadingKey> = []

        var templateWorkout: Workout?
        var alert: AppAlert?

        private let api: WorkoutAPIProtocol

        init(api: WorkoutAPIProtocol = LiveWorkoutAPI()) {
            self.api = api
        }

        @MainActor
        func attemptCreateWorkout(dismissAction: () -> Void) async {
            guard let selectedMovements: [Movement] = self.templateWorkout?.movements_details else {
                return
            }

            try? await withLoading(.action) {
                do {
                    _ = try await self.api.createWorkout(
                        movements: selectedMovements.map { $0.id! })
                    dismissAction()
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
