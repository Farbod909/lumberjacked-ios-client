//
//  CurrentWorkoutView.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/21/25.
//

import SwiftUI

struct CurrentWorkoutView: View {
    @State var viewModel = ViewModel()
    @State var errors = LumberjackedClientErrors()
    @State var timeElapsed: String = "00:00"
    @EnvironmentObject var appEnvironment: LumberjackedAppEnvironment
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.currentWorkout == nil {
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        Button {
                            viewModel.showCreateWorkoutSheet.toggle()
                        } label: {
                            Label("New workout", systemImage: "plus")
                        }
                    }
                } else {
                    VStack {
                        Text(timeElapsed)
                            .font(.largeTitle)
                            .onReceive(timer) { _ in
                                let interval = Date.now.timeIntervalSince((viewModel.currentWorkout?.start_timestamp)!)
                                
                                let totalMinutes = Int(interval / 60)
                                let hours = totalMinutes / 60
                                let minutes = totalMinutes % 60

                                timeElapsed = String(format: "%02d:%02d", hours, minutes)
                            }
                    }
                    ScrollView {
                        ForEach(viewModel.currentWorkout?.movements_details ?? [], id: \.self) { movement in
                            CurrentWorkoutMovementView(movement: movement)
                        }
                        Button("End workout") {
                            Task {
                                await viewModel.attemptEndCurrentWorkout(errors: $errors)
                            }
                        }
                        .foregroundStyle(.red)
                        .padding(.vertical, 10)
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .padding(.horizontal, 16)
            .animation(.default, value: viewModel.currentWorkout)
            .task(id: appEnvironment.isNotAuthenticated) {
                await viewModel.attemptGetCurrentWorkout(errors: $errors)
            }
            .sheet(isPresented: $viewModel.showCreateWorkoutSheet, onDismiss: {
                Task {
                    await viewModel.attemptGetCurrentWorkout(errors: $errors)
                }
            }) {
                CreateWorkoutView()
            }
            .navigationTitle("Current Workout")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Movement.self) { movement in
                MovementDetailView(viewModel: MovementDetailView.ViewModel(movement: movement))
            }
            .navigationDestination(for: MovementLogDestination.self) { movementLogDestination in
                MovementLogInputView(
                    viewModel: MovementLogInputView.ViewModel(
                        movementLog: movementLogDestination.log,
                        movement: movementLogDestination.movement,
                        workout: viewModel.currentWorkout!))
            }
            .toolbar {
                if viewModel.currentWorkout != nil {
                    ToolbarItem(placement: .confirmationAction) {
                        NavigationLink("Edit") {
                            MovementSelectorView(
                                viewModel: MovementSelectorView.ViewModel(workout: viewModel.currentWorkout)
                            )
                        }
                    }
                    ToolbarItem(placement: .secondaryAction) {
                        Button {
                            viewModel.showCancelConfirmationAlert = true
                        } label: {
                            Label("Cancel workout", systemImage: "trash")
                        }
                    }
                }
            }
            .alert("Cancel Workout", isPresented: $viewModel.showCancelConfirmationAlert) {
                Button("Yes", role: .destructive) {
                    Task {
                        await viewModel.attemptDeleteCurrentWorkout(errors: $errors)
                    }
                }
                Button("No", role: .cancel) {}
            }
        }
    }
}

#Preview {
    CurrentWorkoutView()
}
