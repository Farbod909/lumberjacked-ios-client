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
    @Namespace private var animation
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    func dismissAddMovementOverlay() {
        viewModel.searchText = ""
        viewModel.showAddMovementOverlay = false
    }
    
    var sharedAnimationBackground: some View {
        RoundedRectangle(cornerRadius: viewModel.showAddMovementOverlay ? 10 : 25)
            .fill(viewModel.showAddMovementOverlay ? Color.white.opacity(0.15) : Color.brandSecondary)
            .frame(
                maxWidth: viewModel.showAddMovementOverlay ? .infinity : 200,
                maxHeight: viewModel.showAddMovementOverlay ? 55 : 50
            )
            .matchedGeometryEffect(id: "background", in: animation)
            .onTapGesture {
                if !viewModel.showAddMovementOverlay {
                    viewModel.showAddMovementOverlay = true
                    addMovementTextFieldFocusState = true
                }
            }
    }
    
    var newWorkoutOptionsOverlayContent: some View {
        HStack {
            Image(systemName: "plus")
            Text("New workout")
        }
        .font(.headline.weight(.semibold))
        .foregroundStyle(Color.brandPrimaryText)
        .matchedGeometryEffect(id: "content", in: animation)
        .onTapGesture {
            Task {
                viewModel.showAddMovementOverlay = true
                addMovementTextFieldFocusState = true
                await viewModel.attemptGetMovements(errors: $errors)
            }
        }
    }
    
    var addMovementButton: some View {
        Button {
            viewModel.showAddMovementOverlay = true
            addMovementTextFieldFocusState = true
        } label: {
            Label("Movement", systemImage: "plus")
                .font(.headline)
        }
        .padding()
        .background(.ultraThinMaterial)
        .foregroundStyle(Color.brandPrimaryText)
        .clipShape(RoundedRectangle(cornerRadius: 25))
    }
    
    var addMovementOverlayContent: some View {
        HStack {
            TextField("",
                      text: $viewModel.searchText,
                      prompt: Text("Enter movement name...").foregroundStyle(.white.opacity(0.6)))
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .keyboardType(.alphabet)
            .focused($addMovementTextFieldFocusState)
            .foregroundStyle(Color.brandPrimaryText)
            .padding(.horizontal, 16)
            .frame(height: 44)
            
            Button {
                dismissAddMovementOverlay()
            } label: {
                Image(systemName: "xmark.circle")
                    .foregroundStyle(.white.opacity(0.6))
                    .padding()
            }
        }
        .matchedGeometryEffect(id: "content", in: animation)
    }
    
    var endWorkoutButton: some View {
        Button {
            Task {
                await viewModel.attemptEndCurrentWorkout(errors: $errors)
            }
        } label: {
            Label("End workout", systemImage: "xmark")
                .font(.headline)
        }
        .padding()
        .background(.ultraThinMaterial)
        .foregroundStyle(Color.accentColor)
        .clipShape(RoundedRectangle(cornerRadius: 25))
    }
    
    var currentWorkoutView: some View {
        ZStack {
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
                    Spacer().frame(height: 100)
                }
                .scrollIndicators(.hidden)
            }
            .padding(.horizontal, 16)
            HStack {
                Spacer().frame(width: 25)
                VStack {
                    Spacer()
                    endWorkoutButton
                    Spacer().frame(height: 20)
                }
                Spacer()
                VStack {
                    Spacer()
                    addMovementButton
                    Spacer().frame(height: 20)
                }
                Spacer().frame(width: 25)
            }
        }
    }
    
    var movementSearchResultsList: some View {
        List {
            Section {
                if !viewModel.searchText.isEmpty {
                    Button {
                        Task {
                            viewModel.isLoading = true
                            if let newMovement = await viewModel.attemptQuickAddMovement(
                                movementName: formattedSearchText,
                                errors: $errors) {
                                if let _ = viewModel.currentWorkout {
                                    await viewModel.addMovementToCurrentWorkout(
                                        errors: $errors, movementId: newMovement.id!)
                                } else {
                                    await viewModel.createWorkoutWithInitialMovement(
                                        errors: $errors, movementId: newMovement.id!)
                                }
                                await viewModel.attemptGetCurrentWorkout(errors: $errors)
                            }
                            dismissAddMovementOverlay()
                            viewModel.isLoading = false
                        }
                    } label: {
                        VStack(alignment: .leading) {
                            Label("Quick Add \"\(formattedSearchText)\"", systemImage: "plus")
                            Text("Quick-added movements can be edited later.")
                                .foregroundStyle(.gray)
                                .font(.caption2)
                                .padding(EdgeInsets(top: 1, leading: 0, bottom: 0, trailing: 0))
                        }
                    }
                }
            }
            .listSectionSpacing(.compact)
            Section {
                ForEach(Array(movementSearchResults), id: \.self) { (movement: Movement) in
                    Button {
                        Task {
                            if let _ = viewModel.currentWorkout {
                                viewModel.isLoading = true
                                dismissAddMovementOverlay()
                                await viewModel.addMovementToCurrentWorkout(
                                    errors: $errors, movementId: movement.id!)
                                await viewModel.attemptGetCurrentWorkout(errors: $errors)
                                viewModel.isLoading = false
                            } else {
                                dismissAddMovementOverlay()
                                viewModel.isLoading = true
                                await viewModel.createWorkoutWithInitialMovement(
                                    errors: $errors, movementId: movement.id!)
                                await viewModel.attemptGetCurrentWorkout(errors: $errors)
                                viewModel.isLoading = false
                            }
                        }
                    } label: {
                        HStack {
                            Text(movement.name)
                            Spacer()
                            if let movementIds = self.viewModel.currentWorkout?.movements_details?.map({ $0.id }),
                               movementIds.contains(movement.id) {
                                Text("Added").font(.caption2).textCase(.uppercase)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
            .listSectionSpacing(.compact)
        }
        .listStyle(.inset)
    }
        
    var movementSearchResults: [Movement] {
        if viewModel.searchText.isEmpty {
            return []
        } else {
            return viewModel.allMovements.filter {
                $0.name.lowercased().contains(viewModel.searchText.lowercased())
            }
        }
    }
    
    var formattedSearchText: String {
        return viewModel.searchText.trimmingCharacters(in: [" "]) .capitalized
    }
    
    var overlay: some View {
        Color(.brandBackground).ignoresSafeArea()
    }
    
    var overlayContent : some View {
        VStack {
            ZStack {
                sharedAnimationBackground
                
                if viewModel.showAddMovementOverlay {
                    addMovementOverlayContent
                } else {
                    newWorkoutOptionsOverlayContent
                }
                
            }
            .padding(.horizontal)
            
            if viewModel.showAddMovementOverlay {
                if viewModel.searchText.isEmpty {
                    Spacer()
                } else {
                    movementSearchResultsList
                }
            }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.currentWorkout != nil {
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        currentWorkoutView
                    }
                }
                
                if viewModel.currentWorkout == nil || viewModel.showAddMovementOverlay {
                    overlay
                    
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        overlayContent
                    }
                }
            }
            .animation(.default, value: viewModel.currentWorkout)
            .animation(.spring(duration: 0.3, bounce: 0.05), value: viewModel.showAddMovementOverlay)
            .task(id: appEnvironment.isNotAuthenticated) {
                viewModel.isLoading = true
                await viewModel.attemptGetCurrentWorkout(errors: $errors)
                await viewModel.attemptGetMovements(errors: $errors)
                viewModel.isLoading = false
            }
            .sheet(isPresented: $viewModel.showCreateWorkoutSheet, onDismiss: {
                Task {
                    viewModel.isLoading = true
                    await viewModel.attemptGetCurrentWorkout(errors: $errors)
                    viewModel.isLoading = false
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
