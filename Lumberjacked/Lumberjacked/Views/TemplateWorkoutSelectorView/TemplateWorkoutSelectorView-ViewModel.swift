//
//  TemplateWorkoutSelectorView-ViewModel.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/22/25.
//

import SwiftUI

extension TemplateWorkoutSelectorView {
    @Observable
    class ViewModel {
        var workouts = [Workout]()
        var isLoading = true
        
        func attemptGetWorkouts(errors: Binding<LumberjackedClientErrors>) async {
            isLoading = true
            if let response = await LumberjackedClient(errors: errors).getWorkouts() {
                workouts = response.results
            }
            isLoading = false
        }
    }
}
