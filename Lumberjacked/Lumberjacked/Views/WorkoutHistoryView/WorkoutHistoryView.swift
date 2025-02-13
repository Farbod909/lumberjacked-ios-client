//
//  WorkoutHistoryView.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/21/25.
//

import SwiftUI

struct WorkoutHistoryView: View {
    @State var viewModel = ViewModel()
    @State var errors = LumberjackedClientErrors()

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.pastWorkouts, id: \.self) { workout in
                    WorkoutOverviewView(workout: workout)
                }
            }
            .listRowSpacing(10)
            .navigationTitle("Workout History")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await viewModel.attemptGetWorkouts(errors: $errors)
            }
        }
    }
}

#Preview {
    WorkoutHistoryView()
}
