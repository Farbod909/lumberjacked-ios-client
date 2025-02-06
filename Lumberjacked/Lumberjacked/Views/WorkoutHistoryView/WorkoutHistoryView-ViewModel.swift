//
//  WorkoutHistoryView-ViewModel.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/21/25.
//

import SwiftUI

extension WorkoutHistoryView {
    @Observable
    class ViewModel {
        var isLoading = true
        var workouts = [Workout]()
        var pastWorkouts: [Workout] {
            workouts.filter { $0.end_timestamp != nil }
        }
        
        func attemptGetWorkouts(errors: Binding<LumberjackedClientErrors>) async {
            isLoading = true
            if let response = await LumberjackedClient(errors: errors).getWorkouts() {
                workouts = response.results
            }
            isLoading = false
        }
    }
}
