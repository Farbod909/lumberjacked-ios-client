//
//  WorkoutTemplateEditorView+ViewModel.swift
//  Lumberjacked
//

import Foundation

extension WorkoutTemplateEditorView {
    @Observable
    class ViewModel: LoadingTrackable {
        enum LoadingKey { case movements, action }
        var loadingKeys: Set<LoadingKey> = []

        let existingTemplate: WorkoutTemplate?

        var name: String
        var selectedMovements: [Movement]
        var allMovements: [Movement] = []
        var searchText: String = ""
        var alert: AppAlert?

        private let templateAPI: WorkoutTemplateAPIProtocol
        private let movementAPI: MovementAPIProtocol

        init(
            template: WorkoutTemplate?,
            templateAPI: WorkoutTemplateAPIProtocol = LiveWorkoutTemplateAPI(),
            movementAPI: MovementAPIProtocol = LiveMovementAPI()
        ) {
            self.existingTemplate = template
            self.templateAPI = templateAPI
            self.movementAPI = movementAPI
            self.name = template?.name ?? ""
            self.selectedMovements = template?.movements_details?
                .sorted { ($0.order ?? 0) < ($1.order ?? 0) }
                .compactMap { $0.movement_detail } ?? []
        }

        var isEditMode: Bool { existingTemplate != nil }

        var isDirty: Bool {
            guard let original = existingTemplate else {
                return !name.isEmpty || !selectedMovements.isEmpty
            }
            let originalMovementIds = original.movements_details?
                .sorted { ($0.order ?? 0) < ($1.order ?? 0) }
                .compactMap { $0.movement?.description } ?? []
            let currentMovementIds = selectedMovements.compactMap { $0.id?.description }
            return name != original.name || currentMovementIds != originalMovementIds
        }

        var canSave: Bool {
            !name.trimmingCharacters(in: .whitespaces).isEmpty
            && !selectedMovements.isEmpty
            && isDirty
        }

        var searchResults: [Movement] {
            guard !searchText.isEmpty else { return [] }
            return allMovements.filter {
                $0.name.lowercased().contains(searchText.lowercased())
            }
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
            let request = CreateWorkoutTemplateRequest(
                name: name.trimmingCharacters(in: .whitespaces),
                movements: selectedMovements.enumerated().map {
                    CreateWorkoutTemplateMovementItem(movement: $0.element.id!)
                }
            )
            try? await withLoading(.action) {
                do {
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
