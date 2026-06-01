//
//  CreateWorkoutView-ViewModel.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/22/25.
//

import SwiftUI

extension CreateWorkoutView {
    @Observable
    class ViewModel {
        var templateWorkout: Workout?
        var isLoadingToolbarAction = false
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

            isLoadingToolbarAction = true
            errors.messages = [:]
            do {
                _ = try await api.createWorkout(
                    movements: selectedMovements.map { $0.id! })
                dismissAction()
            } catch let error as RemoteNetworkingError {
                if let messages = error.messages {
                    errors.messages = messages
                } else {
                    errors.messages["detail"] = "Unknown error"
                }
            } catch {
                errors.messages["detail"] = "Unknown error"
            }
            isLoadingToolbarAction = false
        }
    }
}
