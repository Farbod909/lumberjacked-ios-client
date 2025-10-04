//
//  WorkoutDetailView-ViewModel.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/22/25.
//

import SwiftUI

extension WorkoutDetailView {
    @Observable
    class ViewModel {
        var workout: Workout
        
        var showDeleteConfirmationAlert = false
        var deleteActionLoading = false
        
        init(workout: Workout) {
            self.workout = workout
        }
        
        func attemptDeleteWorkout(errors: Binding<LumberjackedClientErrors>) async -> Bool {
            deleteActionLoading = true
            let success = await LumberjackedClient(errors: errors)
                .deleteWorkout(id: self.workout.id!)
            deleteActionLoading = false
            return success
        }

    }
}
