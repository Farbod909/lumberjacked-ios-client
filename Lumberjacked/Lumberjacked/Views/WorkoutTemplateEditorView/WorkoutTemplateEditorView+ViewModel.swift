//
//  WorkoutTemplateEditorView+ViewModel.swift
//  Lumberjacked
//

import Foundation

extension WorkoutTemplateEditorView {

    struct EditableTemplateMovementEntry: Identifiable {
        let movement: Movement
        var templateSets: [TemplateSet]

        var id: UInt64 { movement.id ?? 0 }

        init(from movement: Movement) {
            self.movement = movement
            self.templateSets = movement.template?.sets ?? []
        }

        init(fromCurrentWorkout entry: CurrentWorkoutView.EditableMovementEntry) {
            self.movement = entry.movement
            let logSets = entry.logSets
            if !logSets.isEmpty {
                self.templateSets = logSets.map {
                    TemplateSet(reps: $0.reps > 0 ? String($0.reps) : "", type: $0.type, rest_time: $0.rest_time)
                }
            } else if let sets = entry.movement.template?.sets, !sets.isEmpty {
                self.templateSets = sets
            } else {
                self.templateSets = []
            }
        }

        init(fromWorkoutDetail entry: WorkoutDetailView.EditableMovementEntry) {
            self.movement = entry.movement
            let logSets = entry.logSets
            if !logSets.isEmpty {
                self.templateSets = logSets.map {
                    TemplateSet(reps: $0.reps > 0 ? String($0.reps) : "", type: $0.type, rest_time: $0.rest_time)
                }
            } else if let sets = entry.movement.template?.sets, !sets.isEmpty {
                self.templateSets = sets
            } else {
                self.templateSets = []
            }
        }
    }

    // MARK: - ViewModel

    @Observable
    class ViewModel: LoadingTrackable {
        enum LoadingKey { case movements, action }
        var loadingKeys: Set<LoadingKey> = []

        let existingTemplate: WorkoutTemplate?
        var name: String
        var entries: [EditableTemplateMovementEntry]
        var allMovements: [Movement] = []
        var searchText: String = ""
        var alert: AppAlert?
        var showAddMovementOverlay = false

        private let templateAPI: WorkoutTemplateAPIProtocol
        private let movementAPI: MovementAPIProtocol

        init(
            template: WorkoutTemplate?,
            initialEntries: [EditableTemplateMovementEntry]? = nil,
            templateAPI: WorkoutTemplateAPIProtocol = LiveWorkoutTemplateAPI(),
            movementAPI: MovementAPIProtocol = LiveMovementAPI()
        ) {
            self.existingTemplate = template
            self.templateAPI = templateAPI
            self.movementAPI = movementAPI
            self.name = template?.name ?? ""

            if let initial = initialEntries {
                self.entries = initial
            } else if let template {
                self.entries = (template.movements_details ?? [])
                    .sorted { ($0.order ?? 0) < ($1.order ?? 0) }
                    .compactMap { wtm -> EditableTemplateMovementEntry? in
                        guard var movement = wtm.movement_detail else { return nil }
                        movement.template = wtm.movement_log_template_detail
                        return EditableTemplateMovementEntry(from: movement)
                    }
            } else {
                self.entries = []
            }
        }

        var isEditMode: Bool { existingTemplate != nil }

        var isDirty: Bool {
            guard let original = existingTemplate else { return true }
            if name != original.name { return true }
            let originalMovements = (original.movements_details ?? [])
                .sorted { ($0.order ?? 0) < ($1.order ?? 0) }
            if entries.count != originalMovements.count { return true }
            for (entry, wtm) in zip(entries, originalMovements) {
                if entry.movement.id != wtm.movement { return true }
                let originalSets = wtm.movement_log_template_detail?.sets ?? []
                if entry.templateSets != originalSets { return true }
            }
            return false
        }

        var canSave: Bool {
            !name.trimmingCharacters(in: .whitespaces).isEmpty
                && !entries.isEmpty
                && isDirty
                && entries.allSatisfy { entry in
                    entry.templateSets.allSatisfy { !$0.reps.trimmingCharacters(in: .whitespaces).isEmpty }
                }
        }

        var searchResults: [Movement] {
            guard !searchText.isEmpty else { return [] }
            return allMovements.filter {
                $0.name.lowercased().contains(searchText.lowercased())
            }
        }

        func addMovement(_ movement: Movement) {
            guard !entries.contains(where: { $0.movement.id == movement.id }) else { return }
            entries.append(EditableTemplateMovementEntry(from: movement))
        }

        func replaceMovement(id: UInt64, with movement: Movement) {
            guard let idx = entries.firstIndex(where: { $0.movement.id == id }) else { return }
            entries[idx] = EditableTemplateMovementEntry(from: movement)
        }

        func removeMovement(id: UInt64) {
            entries.removeAll { $0.movement.id == id }
        }

        func attemptGetMovements() async {
            try? await withLoading(.movements) {
                do {
                    let response = try await self.movementAPI.getMovements()
                    self.allMovements = response.results
                } catch {
                    self.alert = AppAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }

        @MainActor
        func save(onSuccess: @escaping (WorkoutTemplate) -> Void) async {
            try? await withLoading(.action) {
                do {
                    let request = CreateWorkoutTemplateRequest(
                        name: self.name.trimmingCharacters(in: .whitespaces),
                        movements: self.entries.map { entry in
                            let sets = entry.templateSets.filter { !$0.reps.trimmingCharacters(in: .whitespaces).isEmpty }
                            return CreateWorkoutTemplateMovementItem(
                                movement: entry.movement.id!,
                                sets: sets.isEmpty ? nil : sets
                            )
                        }
                    )
                    let saved: WorkoutTemplate
                    if let id = self.existingTemplate?.id {
                        saved = try await self.templateAPI.updateWorkoutTemplate(id: id, request: request)
                    } else {
                        saved = try await self.templateAPI.createWorkoutTemplate(request: request)
                    }
                    onSuccess(saved)
                } catch {
                    self.alert = AppAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
}
