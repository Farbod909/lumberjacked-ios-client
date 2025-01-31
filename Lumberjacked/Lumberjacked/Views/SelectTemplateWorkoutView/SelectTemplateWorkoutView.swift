//
//  SelectTemplateWorkoutView.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/22/25.
//

import SwiftUI

struct SelectTemplateWorkoutView: View {
    @State var viewModel = ViewModel()
    @Binding var templateWorkout: Workout?
    @State var errors = LumberjackedClientErrors()
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView()
            } else {
                List {
                    Picker("Build a new workout from scratch or choose a past workout as a template.", selection: $templateWorkout) {
                        Text("Build from scratch").tag(Optional<Workout>(nil))
                        ForEach(viewModel.workouts, id: \.self.id) { workout in
                            WorkoutOverviewView(workout: workout)
                                .tag(Optional(workout))
                        }
                    }
                    .pickerStyle(.inline)
                }
                .listRowSpacing(10)
            }
        }
        .task {
            await viewModel.attemptGetWorkouts(errors: $errors)
        }
    }
}

#Preview {
    struct Preview: View {
        @State var templateWorkout: Workout? = nil
        
        var body: some View {
            SelectTemplateWorkoutView(templateWorkout: $templateWorkout)
        }
    }

    return Preview()
}
