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
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.workouts.isEmpty {
                emptyState
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

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 52))
                .foregroundStyle(.secondary)
            Text("No past workouts")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Complete a workout first to\nrepeat it here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
            Spacer()
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity)
    }
}

#if DEBUG
#Preview("With Workouts") {
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

#Preview("Empty") {
    struct Preview: View {
        @State var templateWorkout: Workout? = nil
        var body: some View {
            NavigationStack {
                TemplateWorkoutSelectorView(
                    viewModel: {
                        let vm = TemplateWorkoutSelectorView.ViewModel(api: MockWorkoutAPI())
                        vm.loadingKeys = []
                        vm.workouts = []
                        return vm
                    }(),
                    templateWorkout: $templateWorkout,
                    dismissAction: { })
            }
        }
    }
    return Preview()
}
#endif
