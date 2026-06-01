//
//  MovementInputView-ViewModel.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/22/25.
//

import SwiftUI

extension MovementInputView {
    @Observable
    class ViewModel {
        var movement: Movement
        var saveActionLoading = false
        var errors = LumberjackedClientErrors()

        private let api: MovementAPIProtocol

        init(movement: Movement, api: MovementAPIProtocol = LiveMovementAPI()) {
            self.movement = movement
            self.api = api
        }

        @MainActor
        func attemptSaveNewMovement(dismissAction: () -> Void) async -> Movement? {
            saveActionLoading = true
            errors.messages = [:]
            do {
                let created = try await api.createMovement(movement: movement)
                dismissAction()
                return created
            } catch let error as RemoteNetworkingError {
                if let messages = error.messages {
                    errors.messages = messages
                } else {
                    errors.messages["detail"] = "Unknown error"
                }
            } catch {
                errors.messages["detail"] = "Unknown error"
            }
            saveActionLoading = false
            return nil
        }

        @MainActor
        func attemptUpdateMovement(dismissAction: () -> Void) async {
            guard let movementId = movement.id else {
                print("No Movement ID")
                return
            }
            saveActionLoading = true
            errors.messages = [:]
            do {
                _ = try await api.updateMovement(movementId: movementId, movement: movement)
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
            saveActionLoading = false
        }
    }
}
