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
        var fieldErrors: [String: String] = [:]
        var alert: AppAlert?

        private let api: MovementAPIProtocol

        init(movement: Movement, api: MovementAPIProtocol = LiveMovementAPI()) {
            self.movement = movement
            self.api = api
        }

        @MainActor
        func attemptSaveNewMovement(dismissAction: () -> Void) async -> Movement? {
            saveActionLoading = true
            fieldErrors = [:]
            do {
                let created = try await api.createMovement(movement: movement)
                dismissAction()
                return created
            } catch let error as RemoteNetworkingError {
                handleNetworkError(error)
            } catch {
                alert = AppAlert(title: "Error", message: error.localizedDescription)
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
            fieldErrors = [:]
            do {
                _ = try await api.updateMovement(movementId: movementId, movement: movement)
                dismissAction()
            } catch let error as RemoteNetworkingError {
                handleNetworkError(error)
            } catch {
                alert = AppAlert(title: "Error", message: error.localizedDescription)
            }
            saveActionLoading = false
        }

        private func handleNetworkError(_ error: RemoteNetworkingError) {
            guard let messages = error.messages else {
                alert = AppAlert(title: "Error", message: "Unknown error")
                return
            }
            for (key, value) in messages {
                let message = extractString(from: value)
                if key == "detail" || key == "non_field_errors" {
                    alert = AppAlert(title: "Error", message: message)
                } else {
                    fieldErrors[key] = message
                }
            }
        }

        private func extractString(from value: Any) -> String {
            if let arr = value as? NSArray {
                return arr.compactMap { $0 as? String }.joined(separator: "\n")
            }
            if let str = value as? String { return str }
            return "Unknown error"
        }
    }
}
