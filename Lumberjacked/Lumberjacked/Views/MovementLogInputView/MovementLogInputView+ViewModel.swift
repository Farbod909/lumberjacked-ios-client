//
//  MovementLogInputView+ViewModel.swift
//  Lumberjacked
//

import SwiftUI

extension MovementLogInputView {
    @Observable
    class ViewModel {
        var movement: Movement
        var movementLog: MovementLog

        // The sets being edited — two-way bound to SetLogInputView.
        var sets: [LogSet]

        var toolbarActionLoading = false
        var alert: AppAlert?

        private let workout: Workout?
        private let api: MovementLogAPIProtocol

        var inputMode: SetLogInputMode {
            if workout != nil {
                return .activeWorkout(previousSets: movement.latest_log?.sets)
            }
            return .editLog
        }

        init(
            movementLog: MovementLog,
            movement: Movement,
            workout: Workout?,
            api: MovementLogAPIProtocol = LiveMovementLogAPI()
        ) {
            self.movementLog = movementLog
            self.movement    = movement
            self.workout     = workout
            self.api         = api
            self.sets        = movementLog.sets ?? []
        }

        func canSave() -> Bool {
            !sets.isEmpty && sets.allSatisfy { $0.reps > 0 }
        }

        // MARK: - Save / Delete

        @MainActor
        func formSubmit(dismissAction: () -> Void) async {
            toolbarActionLoading = true
            let success: Bool
            if movementLog.id == nil {
                success = await attemptSaveNewLog()
            } else {
                success = await attemptUpdateLog()
            }
            toolbarActionLoading = false
            if success { dismissAction() }
        }

        @MainActor
        func attemptDeleteLog(dismissAction: () -> Void) async {
            guard let id = movementLog.id else { return }
            toolbarActionLoading = true
            do {
                try await api.deleteLog(movementLogId: id)
                toolbarActionLoading = false
                dismissAction()
            } catch let error as RemoteNetworkingError {
                handleNetworkError(error)
                toolbarActionLoading = false
            } catch {
                alert = AppAlert(title: "Error", message: error.localizedDescription)
                toolbarActionLoading = false
            }
        }

        private func buildLogForSubmission() -> MovementLog {
            var result = movementLog
            result.sets = sets
            result.for_current_workout = nil
            result.timestamp = nil
            if movementLog.id == nil {
                result.workout_movement = movement.workout_movement_id
            }
            return result
        }

        private func attemptSaveNewLog() async -> Bool {
            do {
                _ = try await api.createLog(movementLog: buildLogForSubmission())
                return true
            } catch let error as RemoteNetworkingError {
                handleNetworkError(error)
            } catch {
                await MainActor.run { alert = AppAlert(title: "Error", message: error.localizedDescription) }
            }
            return false
        }

        private func attemptUpdateLog() async -> Bool {
            guard let id = movementLog.id else { return false }
            do {
                _ = try await api.updateLog(movementLogId: id, movementLog: buildLogForSubmission())
                return true
            } catch let error as RemoteNetworkingError {
                handleNetworkError(error)
            } catch {
                await MainActor.run { alert = AppAlert(title: "Error", message: error.localizedDescription) }
            }
            return false
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
                    alert = AppAlert(title: "Error (\(key))", message: message)
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
