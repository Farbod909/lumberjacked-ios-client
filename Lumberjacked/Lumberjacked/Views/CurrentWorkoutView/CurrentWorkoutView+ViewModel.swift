//
//  CurrentWorkout-ViewModel.swift
//  Lumberjacked
//

import SwiftUI

// MARK: - Editable movement entry

extension CurrentWorkoutView {

    struct EditableMovementEntry: Identifiable {
        let movement: Movement
        var movementNotes: String
        var logSets: [LogSet]
        var logNotes: String
        var existingLogId: UInt64?

        var id: UInt64 { movement.id ?? 0 }

        init(from movement: Movement) {
            self.movement = movement
            self.movementNotes = movement.notes
            if let log = movement.latest_log, log.for_current_workout == true {
                // In-progress session: restore exactly what was saved
                self.logSets       = log.sets ?? []
                self.logNotes      = log.notes
                self.existingLogId = log.id
            } else if let templateSets = movement.template?.sets, !templateSets.isEmpty {
                // Template exists: seed rows from template with reps left empty (shown as placeholder).
                // Loads are carried from latest_log using a greedy left-to-right type-match: for each
                // template set, claim the first unclaimed historical set of the same type and take its
                // load. This is more robust than a purely positional match because it handles reordering
                // and count mismatches gracefully, without inventing cross-type associations.
                //
                // Template: W, 1, 2, F      History: W, 1, 2, F
                // → W←W  1←1  2←2  F←F     (all loads carried, identical shapes)
                //
                // Template: W, 1, M, F      History: W, 1, F, M  (order swapped)
                // → W←W  1←1  M←M  F←F     (loads still carried despite reordering)
                //
                // Template: W, 1, M, F      History: W, 1, 2, F, M  (extra working set in history)
                // → W←W  1←1  M←M  F←F     (extra history working set at pos 2 is skipped over)
                //
                // Template: W, 1, 2, 3      History: 1, 2, 3  (template adds a warmup)
                // → W←nil  1←1  2←2  3←3   (no W in history → warmup gets no load)
                //
                // Template: W, 1, 2         History: W, 1, 2, 3  (template drops a working set)
                // → W←W  1←1  2←2          (history set at pos 3 is simply unused)
                let stored = UserDefaults.standard.integer(forKey: "defaultRestTime")
                let defaultRest = stored > 0 ? stored : 120
                let historicalSets = movement.latest_log?.sets ?? []
                var claimedIndices = Set<Int>()
                self.logSets = templateSets.map { templateSet in
                    let matchIndex = historicalSets.indices.first {
                        !claimedIndices.contains($0) && historicalSets[$0].type == templateSet.type
                    }
                    if let idx = matchIndex { claimedIndices.insert(idx) }
                    return LogSet(reps: 0, load: nil, type: templateSet.type, rest_time: templateSet.rest_time ?? defaultRest)
                }
                self.logNotes      = ""
                self.existingLogId = nil
            } else if let previousSets = movement.latest_log?.sets, !previousSets.isEmpty {
                let stored = UserDefaults.standard.integer(forKey: "defaultRestTime")
                let defaultRest = stored > 0 ? stored : 120
                // Mirror previous log as placeholders — seed empty rows preserving type/rest
                self.logSets       = previousSets.map { LogSet(reps: 0, load: nil, type: $0.type, rest_time: $0.rest_time ?? defaultRest) }
                self.logNotes      = ""
                self.existingLogId = nil
            } else {
                let stored = UserDefaults.standard.integer(forKey: "defaultRestTime")
                // No previous log, no template: seed one empty working set
                self.logSets       = [LogSet(reps: 0, load: nil, type: "working", rest_time: stored > 0 ? stored : 120)]
                self.logNotes      = ""
                self.existingLogId = nil
            }
        }
    }

    // MARK: - ViewModel

    @Observable
    class ViewModel: LoadingTrackable {
        enum LoadingKey { case currentWorkout, movements, addMovement, endWorkout, deleteWorkout }
        var loadingKeys: Set<LoadingKey> = [.currentWorkout, .movements]

        enum Destination: Identifiable, Hashable {
            case editWorkout
            var id: String {
                switch self {
                case .editWorkout: return "editWorkout"
                }
            }
        }
        var destination: Destination?

        var currentWorkout: Workout?
        var editableEntries: [EditableMovementEntry] = []
        var showCreateWorkoutSheet = false
        var alert: AppAlert?

        var addMovementTextFieldFocused = false
        var showAddMovementOverlay = false

        var allMovements = [Movement]()
        var searchText = ""

        var placeholderWidth: CGFloat = 0

        private let workoutAPI: WorkoutAPIProtocol
        private let movementAPI: MovementAPIProtocol
        private let movementLogAPI: MovementLogAPIProtocol

        init(
            workoutAPI: WorkoutAPIProtocol = LiveWorkoutAPI(),
            movementAPI: MovementAPIProtocol = LiveMovementAPI(),
            movementLogAPI: MovementLogAPIProtocol = LiveMovementLogAPI()
        ) {
            self.workoutAPI = workoutAPI
            self.movementAPI = movementAPI
            self.movementLogAPI = movementLogAPI
        }

        func editWorkoutTapped() { destination = .editWorkout }

        // MARK: - Workout loading

        func attemptGetCurrentWorkout() async {
            try? await withLoading(.currentWorkout) {
                do {
                    self.currentWorkout = try await self.workoutAPI.getCurrentWorkout()
                    self.refreshEditableEntries(from: self.currentWorkout!)
                } catch let error as RemoteNetworkingError {
                    if error.statusCode == 404 {
                        self.currentWorkout = nil
                        self.editableEntries = []
                    } else {
                        self.handleNetworkError(error)
                    }
                } catch {
                    self.alert = AppAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }

        // Merges server state into editableEntries, preserving in-progress edits for
        // movements already known. New movements (e.g. just added) start fresh.
        private func refreshEditableEntries(from workout: Workout) {
            let movements = workout.movements_details ?? []
            editableEntries = movements.map { movement in
                if let existing = editableEntries.first(where: { $0.movement.id == movement.id }) {
                    return existing
                }
                return EditableMovementEntry(from: movement)
            }
        }

        // MARK: - Finish workout (saves all logs + notes, then ends)

        func attemptEndCurrentWorkout() async {
            guard let workoutId = currentWorkout?.id else { return }
            try? await withLoading(.endWorkout) {
                do {
                    // 1. Save any changed movement notes
                    for entry in self.editableEntries {
                        guard let movementId = entry.movement.id,
                              entry.movementNotes != entry.movement.notes else { continue }
                        var updated = entry.movement
                        updated.notes = entry.movementNotes
                        _ = try await self.movementAPI.updateMovement(movementId: movementId, movement: updated)
                    }
                    // 2. Save movement logs for entries that have at least one checked set
                    for entry in self.editableEntries {
                        let validSets = entry.logSets.filter { $0.isChecked && $0.reps > 0 }
                        guard !validSets.isEmpty else { continue }
                        var log = MovementLog(sets: validSets, notes: entry.logNotes)
                        log.for_current_workout = nil
                        log.timestamp = nil
                        if let existingId = entry.existingLogId {
                            _ = try await self.movementLogAPI.updateLog(
                                movementLogId: existingId, movementLog: log)
                        } else {
                            log.workout_movement = entry.movement.workout_movement_id
                            _ = try await self.movementLogAPI.createLog(movementLog: log)
                        }
                    }
                    // 3. End the workout
                    try await self.workoutAPI.endWorkout(id: workoutId)
                    self.currentWorkout = nil
                    self.editableEntries = []
                } catch let error as RemoteNetworkingError {
                    self.handleNetworkError(error)
                } catch {
                    self.alert = AppAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }

        func attemptDeleteCurrentWorkout() async {
            guard let id = currentWorkout?.id else { return }
            try? await withLoading(.deleteWorkout) {
                do {
                    try await self.workoutAPI.deleteWorkout(id: id)
                    self.currentWorkout = nil
                    self.editableEntries = []
                } catch let error as RemoteNetworkingError {
                    self.handleNetworkError(error)
                } catch {
                    self.alert = AppAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }

        // MARK: - Remove movement

        func attemptRemoveMovement(movementId: UInt64) async {
            guard let workoutId = currentWorkout?.id else { return }
            let remaining = editableEntries
                .map { $0.movement.id }
                .compactMap { $0 }
                .filter { $0 != movementId }
            do {
                _ = try await workoutAPI.updateWorkout(workoutId: workoutId, movements: remaining)
                editableEntries.removeAll { $0.movement.id == movementId }
            } catch let error as RemoteNetworkingError {
                handleNetworkError(error)
            } catch {
                alert = AppAlert(title: "Error", message: error.localizedDescription)
            }
        }

        // MARK: - Movement replace

        func replaceMovement(oldId: UInt64, newId: UInt64) async {
            guard let workoutId = currentWorkout?.id else { return }
            let movementIds = editableEntries
                .compactMap { $0.movement.id }
                .map { $0 == oldId ? newId : $0 }
            do {
                _ = try await workoutAPI.updateWorkout(workoutId: workoutId, movements: movementIds)
                await attemptGetCurrentWorkout()
            } catch let error as RemoteNetworkingError {
                handleNetworkError(error)
            } catch {
                alert = AppAlert(title: "Error", message: error.localizedDescription)
            }
        }

        // MARK: - Movement reorder

        func persistMovementOrder() async {
            guard let workoutId = currentWorkout?.id else { return }
            let movementIds = editableEntries.compactMap { $0.movement.id }
            _ = try? await workoutAPI.updateWorkout(workoutId: workoutId, movements: movementIds)
        }

        // MARK: - Movements catalog

        func attemptGetMovements() async {
            try? await withLoading(.movements) {
                do {
                    let response = try await self.movementAPI.getMovements()
                    self.allMovements = response.results
                } catch let error as RemoteNetworkingError {
                    self.handleNetworkError(error)
                } catch {
                    self.alert = AppAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }

        @MainActor
        func addMovementToCurrentWorkout(movementId: UInt64) async {
            if let movementIds = self.currentWorkout?.movements_details?.map({ $0.id }),
               !movementIds.contains(movementId) {
                await attemptAddMovementToCurrentWorkout(addMovementId: movementId) { }
            }
        }

        @MainActor
        func createWorkoutWithInitialMovement(movementId: UInt64) async {
            try? await withLoading(.addMovement) {
                do {
                    _ = try await self.workoutAPI.createWorkout(movements: [movementId])
                } catch let error as RemoteNetworkingError {
                    self.handleNetworkError(error)
                } catch {
                    self.alert = AppAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }

        @MainActor
        func attemptQuickAddMovement(movementName: String) async -> Movement? {
            loadingKeys.insert(.addMovement)
            defer { loadingKeys.remove(.addMovement) }
            do {
                return try await movementAPI.createMovement(
                    movement: Movement(name: movementName, notes: ""))
            } catch let error as RemoteNetworkingError {
                handleNetworkError(error)
            } catch {
                alert = AppAlert(title: "Error", message: error.localizedDescription)
            }
            return nil
        }

        @MainActor
        func attemptAddMovementToCurrentWorkout(addMovementId: UInt64, dismissAction: () -> Void) async {
            if let currentWorkoutMovements = currentWorkout?.movements_details {
                var newMovementsList = currentWorkoutMovements.map { $0.id! }
                newMovementsList.append(addMovementId)
                try? await withLoading(.addMovement) {
                    do {
                        _ = try await self.workoutAPI.updateWorkout(
                            workoutId: self.currentWorkout!.id!,
                            movements: newMovementsList)
                        dismissAction()
                    } catch let error as RemoteNetworkingError {
                        self.handleNetworkError(error)
                    } catch {
                        self.alert = AppAlert(title: "Error", message: error.localizedDescription)
                    }
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
