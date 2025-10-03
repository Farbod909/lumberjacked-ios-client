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
        
        init(workout: Workout) {
            self.workout = workout
        }

    }
}
