//
//  WorkoutDetailView.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/22/25.
//

import SwiftUI

struct WorkoutDetailView: View {
    @State var viewModel: ViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color.brandBackground.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 12) {
                Text(viewModel.workout.humanReadableStartTimestamp ?? "Unknown")
                    .font(.title)
                    .fontWeight(.semibold)
                    .padding(EdgeInsets(top: 0, leading: 6, bottom: 0, trailing: 6))
                HStack {
                    HStack {
                        if let startTimestamp = viewModel.workout.start_timestamp {
                            Text("Start")
                                .textCase(.uppercase)
                                .font(.headline)
                            Text(startTimestamp.formatted(.dateTime.hour().minute()))
                                .foregroundColor(.primary)
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 25).fill(Color.brandSecondary))
                    HStack {
                        if let endTimestamp = viewModel.workout.end_timestamp {
                            Text("End")
                                .textCase(.uppercase)
                                .font(.headline)
                            Text(endTimestamp.formatted(.dateTime.hour().minute()))
                                .foregroundColor(.primary)
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 25).fill(Color.brandSecondary))
                }
                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach(viewModel.workout.movements_details ?? [], id:\.self) { movement in
                            if let movementLog = movement.recorded_log {
                                NavigationLink(destination: MovementLogInputView(
                                    viewModel: MovementLogInputView.ViewModel(
                                        movementLog: movementLog,
                                        movement: movement,
                                        workout: viewModel.workout))) {
                                    HStack(alignment: .top) {
                                        VStack(alignment: .leading) {
                                            Text(movement.name)
                                                .multilineTextAlignment(.leading)
                                                .font(.headline)
                                            VStack {
                                                Spacer()
                                                Text(movementLog.notes)
                                                    .multilineTextAlignment(.leading)
                                                    .font(.subheadline)
                                                Spacer()
                                            }
                                        }
                                        Spacer()
                                        VStack(alignment: .trailing) {
                                            ForEach(movementLog.summary, id:\.self) { item in
                                                Text(item)
                                            }
                                        }
                                        .textCase(.uppercase)
                                    }
                                    .padding()
                                    .background(RoundedRectangle(cornerRadius: 25).fill(Color.brandSecondary))
                                }
                                .foregroundStyle(Color.brandPrimaryText)
                            }
                        }
                    }
                }
                .scrollIndicators(.hidden)

                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 10)
        }
        .task {
            await viewModel.attemptRefreshWorkout()
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                if viewModel.deleteActionLoading {
                    ProgressView()
                }
                Menu {
                    Button(role: .destructive) {
                        viewModel.showDeleteConfirmationAlert = true
                    } label: {
                        Label("Delete workout", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .alert("Delete", isPresented: $viewModel.showDeleteConfirmationAlert) {
            Button("Delete", role: .destructive) {
                Task {
                    guard await viewModel.attemptDeleteWorkout() else {
                        return
                    }
                    dismiss()
                }
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}

#if DEBUG
#Preview("Recent Workout") {
    NavigationStack {
        WorkoutDetailView(viewModel: WorkoutDetailView.ViewModel(
            workout: PreviewData.pastWorkout_today,
            api: MockWorkoutAPI()))
    }
}

#Preview("Older Workout") {
    NavigationStack {
        WorkoutDetailView(viewModel: WorkoutDetailView.ViewModel(
            workout: PreviewData.pastWorkout_2weeksAgo,
            api: MockWorkoutAPI()))
    }
}
#endif
