//
//  TemplateWorkoutSelectorView.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/22/25.
//

import SwiftUI

struct TemplateWorkoutSelectorView: View {
    @State var viewModel: ViewModel
    @Binding var templateWorkout: Workout?

    let dismissAction: () -> Void

    init(viewModel: ViewModel = ViewModel(), templateWorkout: Binding<Workout?>, dismissAction: @escaping () -> Void) {
        _viewModel = State(initialValue: viewModel)
        _templateWorkout = templateWorkout
        self.dismissAction = dismissAction
    }

    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView()
            } else {
                List {
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
                .listRowSpacing(10)
            }
        }
        .task {
            await viewModel.attemptGetWorkouts()
        }
    }
}

#if DEBUG
#Preview {
    struct Preview: View {
        @State var templateWorkout: Workout? = nil

        var body: some View {
            NavigationStack {
                TemplateWorkoutSelectorView(
                    viewModel: TemplateWorkoutSelectorView.ViewModel(api: MockWorkoutAPI()),
                    templateWorkout: $templateWorkout,
                    dismissAction: { })
            }
        }
    }
    return Preview()
}
#endif
