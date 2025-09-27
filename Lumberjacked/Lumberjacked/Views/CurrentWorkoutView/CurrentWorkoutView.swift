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
    @FocusState var addMovementTextFieldFocusState: Bool
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var capsuleTextFieldStyle = BrandTextFieldStyle(cornerRadius: 50)
    var standardTextFieldStyle = BrandTextFieldStyle()

    var currentWorkoutView: some View {
        VStack {
            VStack {
                Text(timeElapsed)
                    .font(.largeTitle)
                    .onReceive(timer) { _ in
                        let interval = Date.now.timeIntervalSince((viewModel.currentWorkout?.start_timestamp) ?? Date.now)
                        
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

    var newWorkoutOptionsView: some View {
        VStack {
            Button {
                viewModel.showAddMovementOverlay = true
                viewModel.addMovementTextFieldFocused = true
            } label: {
                Label("New workout", systemImage: "plus")
            }.buttonStyle(.capsule)
            Button {
                viewModel.showCreateWorkoutSheet.toggle()
            } label: {
                Label("Repeat a past workout", systemImage: "repeat")
            }
            .padding(EdgeInsets(top: 14, leading: 0, bottom: 0, trailing: 0))
        }
    }
    
    var addMovementView: some View {
        VStack {
            TextField("",
                      text: $viewModel.addMovementText,
                      prompt: Text("Enter movement name...").foregroundStyle(.white.opacity(0.6)))
            .textFieldStyle(.brand)
            .focused($addMovementTextFieldFocusState)
            .onChange(of: addMovementTextFieldFocusState) {
                viewModel.addMovementTextFieldFocused = addMovementTextFieldFocusState
                if !addMovementTextFieldFocusState && viewModel.addMovementText.isEmpty {
                    viewModel.showAddMovementOverlay = false
                }
            }
            .onAppear() {
                addMovementTextFieldFocusState = viewModel.addMovementTextFieldFocused
            }
            Spacer()
        }
    }
    
    var promptViewUnfocused: Text {
        Text("\(Image(systemName: "plus")) New workout").foregroundStyle(Color.brandPrimaryText)
    }
    
    var promptViewFocused: Text {
        Text("Enter movement name...").foregroundStyle(.white.opacity(0.6))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // content
                if viewModel.currentWorkout != nil {
                    currentWorkoutView
                }
                
                // overlay
                if viewModel.currentWorkout == nil || viewModel.showAddMovementOverlay {
                    VStack {
                        Spacer()
                    }.background(Color.brandBackground)
                }
                
                // content on top of overlay
//                if viewModel.showAddMovementOverlay {
//                    addMovementView
//                } else {
//                    if viewModel.currentWorkout == nil {
//                        if viewModel.isLoading {
//                            ProgressView()
//                        } else {
//                            newWorkoutOptionsView
//                        }
//                    }
//                }
                
                if viewModel.currentWorkout == nil {
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        VStack {
                            TextField("",
                                      text: $viewModel.addMovementText,
                                      prompt: viewModel.showAddMovementOverlay ? promptViewFocused : promptViewUnfocused)
                            .textFieldStyle(viewModel.showAddMovementOverlay ? standardTextFieldStyle : capsuleTextFieldStyle)
                            .focused($addMovementTextFieldFocusState)
                            .onChange(of: addMovementTextFieldFocusState) {
                                viewModel.addMovementTextFieldFocused = addMovementTextFieldFocusState
                                if addMovementTextFieldFocusState {
                                    viewModel.showAddMovementOverlay = true
                                }
                                if !addMovementTextFieldFocusState && viewModel.addMovementText.isEmpty {
                                    viewModel.showAddMovementOverlay = false
                                }
                            }
                            .onAppear() {
                                addMovementTextFieldFocusState = viewModel.addMovementTextFieldFocused
                            }
                            .background {
                                if !viewModel.showAddMovementOverlay {
                                    promptViewUnfocused
                                        .fixedSize()
                                        .hidden()
                                        .onGeometryChange(for: CGFloat.self) { proxy in
                                            proxy.size.width
                                        } action: { width in
                                            viewModel.placeholderWidth = width + capsuleTextFieldStyle.horizontalPadding * 2 + 10
                                        }
                                }
                            }
                            .multilineTextAlignment(viewModel.showAddMovementOverlay ? .leading : .center)
                            .frame(
                                maxWidth: viewModel.showAddMovementOverlay ? .infinity : viewModel.placeholderWidth)
                            if viewModel.showAddMovementOverlay {
                                Spacer()
                            }
                        }
                    }
                }

            }
            .padding(.horizontal, 16)
            .animation(.default, value: viewModel.currentWorkout)
            .animation(.spring(duration: 0.3, bounce: 0.15), value: viewModel.showAddMovementOverlay)
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
