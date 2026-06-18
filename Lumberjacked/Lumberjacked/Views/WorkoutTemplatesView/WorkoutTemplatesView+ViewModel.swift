//
//  WorkoutTemplatesView+ViewModel.swift
//  Lumberjacked
//

import Foundation

extension WorkoutTemplatesView {
    @Observable
    class ViewModel: LoadingTrackable {
        enum LoadingKey { case templates, action }
        var loadingKeys: Set<LoadingKey> = []

        var templates: [WorkoutTemplate] = []
        var alert: AppAlert?

        private let templateAPI: WorkoutTemplateAPIProtocol
        private let workoutAPI: WorkoutAPIProtocol
        var onWorkoutStarted: ((Workout) -> Void)?

        private static let orderKey = "workoutTemplateOrder"

        init(
            templateAPI: WorkoutTemplateAPIProtocol = LiveWorkoutTemplateAPI(),
            workoutAPI: WorkoutAPIProtocol = LiveWorkoutAPI(),
            onWorkoutStarted: ((Workout) -> Void)? = nil
        ) {
            self.templateAPI = templateAPI
            self.workoutAPI = workoutAPI
            self.onWorkoutStarted = onWorkoutStarted
        }

        // MARK: - Ordering

        var localOrder: [UInt64] {
            get {
                guard let data = UserDefaults.standard.data(forKey: Self.orderKey),
                      let decoded = try? JSONDecoder().decode([UInt64].self, from: data)
                else { return [] }
                return decoded
            }
            set {
                let data = try? JSONEncoder().encode(newValue)
                UserDefaults.standard.set(data, forKey: Self.orderKey)
            }
        }

        var orderedTemplates: [WorkoutTemplate] {
            let order = localOrder
            if order.isEmpty { return templates }
            let ordered = order.compactMap { id in templates.first(where: { $0.id == id }) }
            let unordered = templates.filter { t in !order.contains(t.id ?? 0) }
            return ordered + unordered
        }

        func saveOrder(_ ids: [UInt64]) {
            localOrder = ids
        }

        // MARK: - Fetch

        func attemptGetTemplates() async {
            try? await withLoading(.templates) {
                do {
                    let response = try await self.templateAPI.getWorkoutTemplates()
                    self.templates = response.results
                } catch {
                    self.alert = AppAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }

        // MARK: - Start workout

        @MainActor
        func startWorkout(from template: WorkoutTemplate) async {
            guard let id = template.id else { return }
            try? await withLoading(.action) {
                do {
                    let workout = try await self.workoutAPI.createWorkout(fromTemplate: id)
                    self.onWorkoutStarted?(workout)
                } catch {
                    self.alert = AppAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }

        // MARK: - Delete

        @MainActor
        func deleteTemplate(_ template: WorkoutTemplate) async {
            guard let id = template.id else { return }
            try? await withLoading(.action) {
                do {
                    try await self.templateAPI.deleteWorkoutTemplate(id: id)
                    self.templates.removeAll { $0.id == id }
                    var order = self.localOrder
                    order.removeAll { $0 == id }
                    self.localOrder = order
                } catch {
                    self.alert = AppAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }

        // MARK: - Refresh after edit/create

        func templateSaved(_ template: WorkoutTemplate) {
            if let idx = templates.firstIndex(where: { $0.id == template.id }) {
                templates[idx] = template
            } else {
                templates.append(template)
            }
        }
    }
}
