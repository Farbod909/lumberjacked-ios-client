//
//  WorkoutHistoryView.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/21/25.
//

import SwiftUI

struct WorkoutHistoryView: View {
    @State var viewModel: ViewModel

    init(viewModel: ViewModel = ViewModel()) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading(.load) {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.pastWorkouts.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(viewModel.pastWorkouts, id: \.self) { workout in
                                Button {
                                    viewModel.workoutTapped(workout)
                                } label: {
                                    WorkoutOverviewView(workout: workout)
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .foregroundStyle(.primary)
                                .brandCard()
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                    .refreshable {
                        await viewModel.attemptRefresh()
                    }
                }
            }
            .background(Color.brandBackground.ignoresSafeArea())
            .navigationTitle("Workout History")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await viewModel.attemptGetWorkouts()
            }
            .navigationDestination(item: $viewModel.destination) { dest in
                switch dest {
                case .workoutDetail(let workout):
                    WorkoutDetailView(viewModel: .init(workout: workout))
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 52))
                .foregroundStyle(.secondary)
            Text("No workouts yet")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Complete a workout to see your\nhistory here.")
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
#Preview("With History") {
    WorkoutHistoryView(viewModel: WorkoutHistoryView.ViewModel(api: MockWorkoutAPI()))
}

#Preview("Empty") {
    let vm = WorkoutHistoryView.ViewModel(api: MockWorkoutAPI())
    vm.loadingKeys = []
    vm.workouts = []
    return WorkoutHistoryView(viewModel: vm)
}
#endif
