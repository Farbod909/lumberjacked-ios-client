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
                .padding(.horizontal, 6)
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach($viewModel.editableEntries) { $entry in
                            InlineMovementLogView(
                                movement: entry.movement,
                                movementNotes: .constant(entry.movement.notes),
                                logNotes: $entry.logNotes,
                                logSets: $entry.logSets,
                                mode: .editLog,
                                movementNotesEditable: false
                            )
                        }
                        Spacer().frame(height: 80)
                    }
                }
                .scrollIndicators(.hidden)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 10)
        }
        .task {
            await viewModel.attemptRefreshWorkout()
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                if viewModel.isSaving {
                    ProgressView()
                } else if viewModel.isDirty {
                    Button("Save") {
                        Task { await viewModel.attemptSaveChanges() }
                    }
                    .disabled(!viewModel.canSave())
                }
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
        .alert(item: $viewModel.alert)
        .alert("Delete", isPresented: $viewModel.showDeleteConfirmationAlert) {
            Button("Delete", role: .destructive) {
                Task {
                    guard await viewModel.attemptDeleteWorkout() else { return }
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
            workoutAPI: MockWorkoutAPI(),
            movementLogAPI: MockMovementLogAPI()))
    }
    .environment(RestTimerEnvironment())
}

#Preview("Older Workout") {
    NavigationStack {
        WorkoutDetailView(viewModel: WorkoutDetailView.ViewModel(
            workout: PreviewData.pastWorkout_2weeksAgo,
            workoutAPI: MockWorkoutAPI(),
            movementLogAPI: MockMovementLogAPI()))
    }
    .environment(RestTimerEnvironment())
}
#endif
