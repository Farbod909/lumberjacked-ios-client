//
//  TemplateWorkoutSelectorView.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/22/25.
//

import SwiftUI

struct TemplateWorkoutSelectorView: View {
    @State var viewModel = ViewModel()
    @State var errors = LumberjackedClientErrors()
    @Binding var templateWorkout: Workout?
    
    let dismissAction: () -> Void

    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView()
            } else {
                List {
                    Section(header: Text("Start fresh or choose a past workout as a template.")) {
                        Text("Start fresh")
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                templateWorkout = nil
                            }
                            .listRowInsets(EdgeInsets())
                            .overlay {
                                if templateWorkout == nil {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.accentColor, lineWidth: 3)
                                }
                            }
                        ForEach(viewModel.workouts, id: \.self.id) { workout in
                            WorkoutOverviewView(workout: workout)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    templateWorkout = workout
                                }
                                .listRowInsets(EdgeInsets())
                                .overlay {
                                    if templateWorkout == workout {
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.accentColor, lineWidth: 3)
                                    }
                                }
                        }
                    }
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
            TemplateWorkoutSelectorView(templateWorkout: $templateWorkout, dismissAction: { })
        }
    }

    return Preview()
}
