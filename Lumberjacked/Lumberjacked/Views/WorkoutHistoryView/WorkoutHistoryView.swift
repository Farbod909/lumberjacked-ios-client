//
//  WorkoutHistoryView.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/21/25.
//

import SwiftUI

struct WorkoutHistoryView: View {
    @State var viewModel: ViewModel
    @State var errors = LumberjackedClientErrors()

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
                await viewModel.attemptGetWorkouts(errors: $errors)
            }
        }
    }
}

#if DEBUG
#Preview {
    let vm = WorkoutHistoryView.ViewModel()
    vm.workouts = PreviewData.pastWorkouts
    vm.isLoading = false
    return NavigationStack {
        WorkoutHistoryView(viewModel: vm)
    }
}
#endif
