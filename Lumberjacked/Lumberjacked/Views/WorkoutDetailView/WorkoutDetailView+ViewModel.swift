//
//  WorkoutDetailView+ViewModel.swift
//  Lumberjacked

import SwiftUI

// MARK: - Editable movement entry

extension WorkoutDetailView {

    struct EditableMovementEntry: Identifiable {
        let movement: Movement
        var logSets: [LogSet]
        var logNotes: String
        let existingLogId: UInt64?

        var id: UInt64 { movement.id ?? 0 }

        init(from movement: Movement) {
            self.movement      = movement
            self.logSets       = movement.recorded_log?.sets  ?? []
            self.logNotes      = movement.recorded_log?.notes ?? ""
            self.existingLogId = movement.recorded_log?.id
        }

        var isDirty: Bool {
            logNotes != (movement.recorded_log?.notes ?? "") ||
            logSets  != (movement.recorded_log?.sets  ?? [])
        }
    }

    // MARK: - ViewModel

    @Observable
    class ViewModel {
        var workout: Workout
        var editableEntries: [EditableMovementEntry] = []
        var alert: AppAlert?
        var showDeleteConfirmationAlert = false
        var deleteActionLoading = false
        var isSaving = false

        var isDirty: Bool { editableEntries.contains { $0.isDirty } }

        private let workoutAPI: WorkoutAPIProtocol
        private let movementLogAPI: MovementLogAPIProtocol

        init(
            workout: Workout,
            workoutAPI: WorkoutAPIProtocol = LiveWorkoutAPI(),
            movementLogAPI: MovementLogAPIProtocol = LiveMovementLogAPI()
        ) {
            self.workout        = workout
            self.workoutAPI     = workoutAPI
            self.movementLogAPI = movementLogAPI
            self.editableEntries = (workout.movements_details ?? []).map { EditableMovementEntry(from: $0) }
        }

        // MARK: - Save

        func attemptSaveChanges() async {
            isSaving = true
            do {
                for entry in editableEntries where entry.isDirty {
                    var log = MovementLog(sets: entry.logSets, notes: entry.logNotes)
                    log.for_current_workout = nil
                    log.timestamp = nil
                    if let existingId = entry.existingLogId {
                        _ = try await movementLogAPI.updateLog(
                            movementLogId: existingId, movementLog: log)
                    } else {
                        log.workout_movement = entry.movement.workout_movement_id
                        _ = try await movementLogAPI.createLog(movementLog: log)
                    }
                }
                await attemptRefreshWorkout()
            } catch let error as RemoteNetworkingError {
                handleNetworkError(error)
            } catch {
                alert = AppAlert(title: "Error", message: error.localizedDescription)
            }
            isSaving = false
        }

        // MARK: - Delete

        func attemptDeleteWorkout() async -> Bool {
            guard let id = workout.id else { return false }
            deleteActionLoading = true
            do {
                try await workoutAPI.deleteWorkout(id: id)
                deleteActionLoading = false
                return true
            } catch let error as RemoteNetworkingError {
                handleNetworkError(error)
            } catch {
                alert = AppAlert(title: "Error", message: error.localizedDescription)
            }
            deleteActionLoading = false
            return false
        }

        // MARK: - Refresh

        func attemptRefreshWorkout() async {
            guard let id = workout.id else { return }
            do {
                workout = try await workoutAPI.getWorkout(workoutId: id)
                editableEntries = (workout.movements_details ?? []).map { EditableMovementEntry(from: $0) }
            } catch let error as RemoteNetworkingError {
                handleNetworkError(error)
            } catch {
                alert = AppAlert(title: "Error", message: error.localizedDescription)
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
