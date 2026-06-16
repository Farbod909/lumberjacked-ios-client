//
//  MovementLogInputView.swift
//  Lumberjacked
//

import SwiftUI

struct MovementLogInputView: View {
    @State var viewModel: ViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(RestTimerEnvironment.self) private var restTimer

    var body: some View {
        ZStack {
            Color.brandBackground.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0) {
                // Movement name + date header
                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.movement.name)
                        .font(.title2)
                        .fontWeight(.semibold)
                    if let logDate = viewModel.movementLog.timestamp?.formatted(
                        date: .abbreviated, time: .omitted) {
                        Text(logDate)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("New Log")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 12)

                // Notes field
                TextField(
                    "",
                    text: $viewModel.movementLog.notes,
                    prompt: Text("Notes...").foregroundStyle(.tertiary)
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .padding(.bottom, 4)

                SetLogInputView(
                    mode: viewModel.inputMode,
                    logSets: $viewModel.sets
                )
            }
        }
        .toolbar {
            if viewModel.toolbarActionLoading {
                ToolbarItem(placement: .topBarTrailing) {
                    ProgressView()
                }
            }

            // Rest timer in nav bar (shown while timer is active)
            ToolbarItem(placement: .principal) {
                if restTimer.isRunning {
                    RestTimerNavBarView()
                }
            }

            if viewModel.isDirty {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await viewModel.formSubmit(dismissAction: { dismiss() })
                        }
                    }
                    .disabled(!viewModel.canSave())
                }
            }

            if viewModel.movementLog.id != nil {
                ToolbarItem(placement: .secondaryAction) {
                    Button("Delete log", systemImage: "trash", role: .destructive) {
                        Task {
                            await viewModel.attemptDeleteLog(dismissAction: { dismiss() })
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Nav bar rest timer

struct RestTimerNavBarView: View {
    @Environment(RestTimerEnvironment.self) private var restTimer

    var body: some View {
        Text(restTimer.formattedTimeRemaining)
            .font(.headline.monospacedDigit())
            .foregroundStyle(Color.accentColor)
            .contentTransition(.numericText(countsDown: true))
            .animation(.default, value: restTimer.timeRemaining)
    }
}

// MARK: - Previews

#if DEBUG
#Preview("Active Workout – New Log") {
    NavigationStack {
        MovementLogInputView(
            viewModel: MovementLogInputView.ViewModel(
                movementLog: MovementLog(notes: ""),
                movement: PreviewData.benchPress,
                workout: PreviewData.activeWorkout,
                api: MockMovementLogAPI()
            )
        )
    }
    .environmentObject(LumberjackedAppEnvironment())
    .environment(RestTimerEnvironment())
}

#Preview("Active Workout – With Previous Sets") {
    let log = MovementLog(
        sets: [
            LogSet(reps: 8,  load: 135, type: "warmup",  rest_time: 60),
            LogSet(reps: 10, load: 155, type: "working", rest_time: 120),
            LogSet(reps: 10, load: 155, type: "working", rest_time: 120),
        ],
        notes: ""
    ).withJustInputFields
    NavigationStack {
        MovementLogInputView(
            viewModel: MovementLogInputView.ViewModel(
                movementLog: log,
                movement: PreviewData.benchPress,
                workout: PreviewData.activeWorkout,
                api: MockMovementLogAPI()
            )
        )
    }
    .environmentObject(LumberjackedAppEnvironment())
    .environment(RestTimerEnvironment())
}

#Preview("Edit Past Log") {
    NavigationStack {
        MovementLogInputView(
            viewModel: MovementLogInputView.ViewModel(
                movementLog: PreviewData.log_benchPress_1,
                movement: PreviewData.benchPress,
                workout: nil,
                api: MockMovementLogAPI()
            )
        )
    }
    .environmentObject(LumberjackedAppEnvironment())
    .environment(RestTimerEnvironment())
}

#Preview("Log Without Sets") {
    NavigationStack {
        MovementLogInputView(
            viewModel: MovementLogInputView.ViewModel(
                movementLog: MovementLog(notes: ""),
                movement: PreviewData.deadlift,
                workout: nil,
                api: MockMovementLogAPI()
            )
        )
    }
    .environmentObject(LumberjackedAppEnvironment())
    .environment(RestTimerEnvironment())
}
#endif
