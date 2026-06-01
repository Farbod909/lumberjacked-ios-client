//
//  MovementDetailView-ViewModel.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/22/25.
//

import SwiftUI

extension MovementDetailView {
    @Observable
    class ViewModel {
        var movement: Movement
        var movementLogs = [MovementLog]()
        var workout: Workout?
        var isLoadingMovementLogs = true
        var deleteActionLoading = false
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
            isLoadingMovementLogs = true
            errors.messages = [:]
            do {
                let response = try await movementLogAPI.getMovementLogs(movementId: id)
                movementLogs = response.results
            } catch let error as RemoteNetworkingError {
                if let messages = error.messages {
                    errors.messages = messages
                } else {
                    errors.messages["detail"] = "Unknown error"
                }
            } catch {
                errors.messages["detail"] = "Unknown error"
            }
            isLoadingMovementLogs = false
        }

        func attemptDeleteMovement() async -> Bool {
            guard let id = movement.id else { return false }
            deleteActionLoading = true
            errors.messages = [:]
            do {
                try await movementAPI.deleteMovement(movementId: id)
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
