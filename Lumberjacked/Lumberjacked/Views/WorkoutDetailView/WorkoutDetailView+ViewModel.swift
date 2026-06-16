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
        var isRemoved: Bool = false
        var isPending: Bool = false

        var id: UInt64 { movement.id ?? 0 }

        init(from movement: Movement) {
            self.movement      = movement
            self.logSets       = movement.recorded_log?.sets  ?? []
            self.logNotes      = movement.recorded_log?.notes ?? ""
            self.existingLogId = movement.recorded_log?.id
        }

        var isDirty: Bool {
            isRemoved || isPending ||
            logNotes != (movement.recorded_log?.notes ?? "") ||
            logSets  != (movement.recorded_log?.sets  ?? [])
        }
    }

    // MARK: - ViewModel

    @Observable
    class ViewModel {
        var workout: Workout
        var editableEntries: [EditableMovementEntry] = []
        var editableStartTimestamp: Date = Date()
        var editableEndTimestamp: Date = Date()
        var alert: AppAlert?
        var showDeleteConfirmationAlert = false
        var deleteActionLoading = false
        var isSaving = false

        var showAddMovementOverlay = false
        var allMovements = [Movement]()
        var searchText = ""

        var isDirty: Bool {
            editableEntries.contains { $0.isDirty } ||
            (workout.start_timestamp != nil &&
             !Calendar.current.isDate(editableStartTimestamp, equalTo: workout.start_timestamp!, toGranularity: .minute)) ||
            (workout.end_timestamp != nil &&
             !Calendar.current.isDate(editableEndTimestamp, equalTo: workout.end_timestamp!, toGranularity: .minute))
        }

        func canSave() -> Bool {
            editableEntries.filter { $0.isDirty && !$0.isRemoved }.allSatisfy { entry in
                entry.logSets.isEmpty || entry.logSets.allSatisfy { $0.reps > 0 }
            }
        }

        private let workoutAPI: WorkoutAPIProtocol
        private let movementLogAPI: MovementLogAPIProtocol
        private let movementAPI: MovementAPIProtocol

        init(
            workout: Workout,
            workoutAPI: WorkoutAPIProtocol = LiveWorkoutAPI(),
            movementLogAPI: MovementLogAPIProtocol = LiveMovementLogAPI(),
            movementAPI: MovementAPIProtocol = LiveMovementAPI()
        ) {
            self.workout             = workout
            self.workoutAPI          = workoutAPI
            self.movementLogAPI      = movementLogAPI
            self.movementAPI         = movementAPI
            self.editableEntries       = (workout.movements_details ?? []).map { EditableMovementEntry(from: $0) }
            self.editableStartTimestamp = workout.start_timestamp ?? Date()
            self.editableEndTimestamp   = workout.end_timestamp ?? Date()
        }

        // MARK: - Save

        func attemptSaveChanges() async {
            isSaving = true
            do {
                let savedStartTimestamp = editableStartTimestamp
                var savedEndTimestamp = editableEndTimestamp

                // If start is after end (cross-midnight workout), push end to the next day.
                if savedStartTimestamp > savedEndTimestamp {
                    savedEndTimestamp = Calendar.current.date(
                        byAdding: .day, value: 1, to: savedEndTimestamp) ?? savedEndTimestamp
                    editableEndTimestamp = savedEndTimestamp
                }

                let startTimestampChanged = workout.start_timestamp != nil &&
                    !Calendar.current.isDate(savedStartTimestamp, equalTo: workout.start_timestamp!, toGranularity: .minute)
                let endTimestampChanged = workout.end_timestamp != nil &&
                    !Calendar.current.isDate(savedEndTimestamp, equalTo: workout.end_timestamp!, toGranularity: .minute)

                // Capture pending and dirty entries before any mutations
                let pendingEntries = editableEntries.filter { $0.isPending }
                let dirtyExistingEntries = editableEntries.filter { $0.isDirty && !$0.isRemoved && !$0.isPending }

                // PATCH workout if movements were added or removed
                var updatedWorkout: Workout? = nil
                let hasStructuralChanges = editableEntries.contains { $0.isRemoved || $0.isPending }
                if hasStructuralChanges, let workoutId = workout.id {
                    let movementIds = editableEntries
                        .filter { !$0.isRemoved }
                        .compactMap { $0.movement.id }
                    updatedWorkout = try await workoutAPI.updateWorkout(workoutId: workoutId, movements: movementIds)
                }

                // Save dirty existing entries' logs
                for entry in dirtyExistingEntries {
                    var log = MovementLog(sets: entry.logSets, notes: entry.logNotes)
                    log.for_current_workout = nil
                    log.timestamp = nil
                    if let existingId = entry.existingLogId {
                        if entry.logSets.isEmpty {
                            try await movementLogAPI.deleteLog(movementLogId: existingId)
                        } else {
                            _ = try await movementLogAPI.updateLog(
                                movementLogId: existingId, movementLog: log)
                        }
                    } else if !entry.logSets.isEmpty {
                        log.workout_movement = entry.movement.workout_movement_id
                        _ = try await movementLogAPI.createLog(movementLog: log)
                    }
                }

                // Create logs for pending entries that have sets, using the new workout_movement_ids
                let updatedMovements = updatedWorkout?.movements_details ?? []
                for entry in pendingEntries where !entry.logSets.isEmpty {
                    guard let updated = updatedMovements.first(where: { $0.id == entry.movement.id }),
                          let workoutMovementId = updated.workout_movement_id else { continue }
                    var log = MovementLog(sets: entry.logSets, notes: entry.logNotes)
                    log.for_current_workout = nil
                    log.timestamp = nil
                    log.workout_movement = workoutMovementId
                    _ = try await movementLogAPI.createLog(movementLog: log)
                }

                if (startTimestampChanged || endTimestampChanged), let workoutId = workout.id {
                    _ = try await workoutAPI.updateWorkoutTimestamps(
                        workoutId: workoutId,
                        startTimestamp: startTimestampChanged ? savedStartTimestamp : nil,
                        endTimestamp:   endTimestampChanged   ? savedEndTimestamp   : nil)
                }

                await attemptRefreshWorkout()

                if startTimestampChanged {
                    editableStartTimestamp = savedStartTimestamp
                    workout.start_timestamp = savedStartTimestamp
                }
                if endTimestampChanged {
                    editableEndTimestamp = savedEndTimestamp
                    workout.end_timestamp = savedEndTimestamp
                }
            } catch let error as RemoteNetworkingError {
                handleNetworkError(error)
            } catch {
                alert = AppAlert(title: "Error", message: error.localizedDescription)
            }
            isSaving = false
        }

        // MARK: - Reorder

        func persistMovementOrder() async {
            guard let workoutId = workout.id else { return }
            let movementIds = editableEntries
                .filter { !$0.isRemoved }
                .compactMap { $0.movement.id }
            _ = try? await workoutAPI.updateWorkout(workoutId: workoutId, movements: movementIds)
        }

        // MARK: - Replace

        func replaceEntry(at id: UInt64, with newMovement: Movement) {
            guard let idx = editableEntries.firstIndex(where: { $0.id == id }) else { return }
            editableEntries[idx].isRemoved = true
            var newEntry = EditableMovementEntry(from: newMovement)
            newEntry.isPending = true
            editableEntries.insert(newEntry, at: idx + 1)
        }

        // MARK: - Add movement

        func attemptGetMovements() async {
            do {
                let response = try await movementAPI.getMovements()
                allMovements = response.results
            } catch let error as RemoteNetworkingError {
                handleNetworkError(error)
            } catch {
                alert = AppAlert(title: "Error", message: error.localizedDescription)
            }
        }

        func addPendingMovement(_ movement: Movement) {
            let currentIds = Set(editableEntries.filter { !$0.isRemoved }.compactMap { $0.movement.id })
            guard let movementId = movement.id, !currentIds.contains(movementId) else { return }
            var entry = EditableMovementEntry(from: movement)
            entry.isPending = true
            editableEntries.append(entry)
            searchText = ""
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
                editableStartTimestamp = workout.start_timestamp ?? Date()
                editableEndTimestamp   = workout.end_timestamp ?? Date()
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
