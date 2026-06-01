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
                    ZStack {
                        WorkoutOverviewView(workout: workout)
                        NavigationLink(destination: WorkoutDetailView(viewModel: .init(workout: workout))) {
                            EmptyView()
                        }.opacity(0)
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
        }
    }
}

#if DEBUG
#Preview {
    WorkoutHistoryView(viewModel: WorkoutHistoryView.ViewModel(api: MockWorkoutAPI()))
}
#endif
