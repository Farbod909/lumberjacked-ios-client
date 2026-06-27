//
//  WorkoutHistoryView-ViewModel.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/21/25.
//

import SwiftUI

extension WorkoutHistoryView {
    @Observable
    class ViewModel: LoadingTrackable {
        enum LoadingKey { case load }
        var loadingKeys: Set<LoadingKey> = [.load]

        enum Destination: Identifiable, Hashable {
            case workoutDetail(Workout)
            var id: String {
                switch self {
                case .workoutDetail(let w): return "detail-\(w.id ?? 0)"
                }
            }
        }
        var destination: Destination?

        var workouts = [Workout]()
        var alert: AppAlert?

        var pastWorkouts: [Workout] {
            workouts.filter { $0.end_timestamp != nil }
        }

        private let api: WorkoutAPIProtocol

        init(api: WorkoutAPIProtocol = LiveWorkoutAPI()) {
            self.api = api
        }

        func workoutTapped(_ workout: Workout) {
            destination = .workoutDetail(workout)
        }

        func attemptRefresh() async {
            do {
                let response = try await api.getWorkouts()
                workouts = response.results
            } catch let error as RemoteNetworkingError {
                handleNetworkError(error)
            } catch {
                alert = AppAlert(title: "Error", message: error.localizedDescription)
            }
        }

        func attemptGetWorkouts() async {
            try? await withLoading(.load) {
                do {
                    let response = try await self.api.getWorkouts()
                    self.workouts = response.results
                } catch let error as RemoteNetworkingError {
                    self.handleNetworkError(error)
                } catch {
                    self.alert = AppAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }

        private func handleNetworkError(_ error: RemoteNetworkingError) {
            alert = AppAlert(title: "Error", message: error.localizedDescription)
        }
    }
}
