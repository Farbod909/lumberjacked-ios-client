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

    private let cornerRadius: CGFloat = 12

    var body: some View {
        Group {
            if viewModel.isLoading(.load) {
                ProgressView()
            } else {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(viewModel.workouts, id: \.self.id) { workout in
                            WorkoutOverviewView(workout: workout)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.brandSecondary, in: RoundedRectangle(cornerRadius: cornerRadius))
                                .overlay {
                                    if templateWorkout == workout {
                                        RoundedRectangle(cornerRadius: cornerRadius)
                                            .strokeBorder(Color.accentColor, lineWidth: 3)
                                    }
                                }
                                .contentShape(RoundedRectangle(cornerRadius: cornerRadius))
                                .onTapGesture {
                                    templateWorkout = workout
                                }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
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
