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
        var errors = LumberjackedClientErrors()

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
                self.errors.messages = [:]
                do {
                    _ = try await self.api.createWorkout(
                        movements: selectedMovements.map { $0.id! })
                    dismissAction()
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
