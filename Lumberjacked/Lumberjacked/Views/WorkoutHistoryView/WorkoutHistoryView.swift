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
            List {
                ForEach(viewModel.pastWorkouts, id: \.self) { workout in
                    Button {
                        viewModel.workoutTapped(workout)
                    } label: {
                        WorkoutOverviewView(workout: workout)
                    }
                    .listRowBackground(Color.brandSecondary)
                }
            }
            .listRowSpacing(10)
            .scrollContentBackground(.hidden)
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
}

#if DEBUG
#Preview {
    WorkoutHistoryView(viewModel: WorkoutHistoryView.ViewModel(api: MockWorkoutAPI()))
}
#endif
