//
//  MovementDetailView-ViewModel.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/22/25.
//

import SwiftUI

extension MovementDetailView {
    @Observable
    class ViewModel: LoadingTrackable {
        enum LoadingKey { case logs, delete }
        var loadingKeys: Set<LoadingKey> = [.logs]

        var movement: Movement
        var movementLogs = [MovementLog]()
        var workout: Workout?
        var showDeleteConfirmationAlert = false
        var showEditSheet = false
        var errors = LumberjackedClientErrors()

        private let movementAPI: MovementAPIProtocol
        private let movementLogAPI: MovementLogAPIProtocol

        init(
            movement: Movement,
            movementLogs: [MovementLog] = [],
            movementAPI: MovementAPIProtocol = LiveMovementAPI(),
            movementLogAPI: MovementLogAPIProtocol = LiveMovementLogAPI()
        ) {
            self.movement = movement
            self.movementLogs = movementLogs
            self.movementAPI = movementAPI
            self.movementLogAPI = movementLogAPI
        }

        func attemptGetMovementLogs() async {
            guard let id = movement.id else { return }
            try? await withLoading(.logs) {
                self.errors.messages = [:]
                do {
                    let response = try await self.movementLogAPI.getMovementLogs(movementId: id)
                    self.movementLogs = response.results
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

        func attemptDeleteMovement() async -> Bool {
            guard let id = movement.id else { return false }
            loadingKeys.insert(.delete)
            defer { loadingKeys.remove(.delete) }
            errors.messages = [:]
            do {
                try await movementAPI.deleteMovement(movementId: id)
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
            return false
        }

        func attemptGetMovementDetail(id: UInt64) async {
            errors.messages = [:]
            do {
                movement = try await movementAPI.getMovement(movementId: id)
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
