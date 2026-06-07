//
//  CurrentWorkoutView.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/21/25.
//

import SwiftUI

struct CurrentWorkoutView: View {
    @State var viewModel: ViewModel
    @State var timeElapsed: String = "00:00"
    @EnvironmentObject var appEnvironment: LumberjackedAppEnvironment
    @FocusState var addMovementTextFieldFocusState: Bool

    init(viewModel: ViewModel = ViewModel()) {
        _viewModel = State(initialValue: viewModel)
    }

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    func dismissAddMovementOverlay() {
        addMovementTextFieldFocusState = false
        viewModel.showAddMovementOverlay = false
    }

    var newWorkoutOptionsView: some View {
        VStack {
            Button {
                Task {
                    viewModel.searchText = ""
                    viewModel.showAddMovementOverlay = true
                    addMovementTextFieldFocusState = true
                    await viewModel.attemptGetMovements()
                }
            } label: {
                Label("New workout", systemImage: "plus")
            }
            .font(.headline.weight(.semibold))
            .foregroundStyle(Color.brandPrimaryText)
            .padding()
            .background(Color.brandSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 25))

            Button {
                viewModel.showCreateWorkoutSheet = true
            } label: {
                Label("Repeat a past workout", systemImage: "repeat")
            }
            .foregroundStyle(Color.accent)
            .padding(.top, 14)
        }
    }

    var addMovementButton: some View {
        Button {
            Task {
                viewModel.searchText = ""
                viewModel.showAddMovementOverlay = true
                addMovementTextFieldFocusState = true
                await viewModel.attemptGetMovements()
            }
        } label: {
            Label("Add Movement", systemImage: "plus")
                .font(.headline)
        }
        .padding()
        .background(.ultraThinMaterial)
        .foregroundStyle(Color.brandPrimaryText)
        .clipShape(RoundedRectangle(cornerRadius: 25))
    }

    var addMovementSearchFieldView: some View {
        HStack {
            TextField(
                "",
                text: $viewModel.searchText,
                prompt: Text("Enter movement name...")
                .foregroundStyle(.brandPrimaryText.opacity(0.6))
            )
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .keyboardType(.alphabet)
            .focused($addMovementTextFieldFocusState)
            .foregroundStyle(Color.brandPrimaryText)
            .frame(height: 44)
            .padding(.horizontal, 16)

            if viewModel.isLoading(.movements) {
                ProgressView()
            }
            Button {
                viewModel.searchText = ""
            } label: {
                Image(systemName: "xmark.circle")
                    .foregroundStyle(.brandPrimaryText.opacity(0.6))
                    .padding()
            }
            .opacity(viewModel.searchText.isEmpty ? 0 : 1)
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.brandSecondary)
        )
        .padding(.horizontal, 16)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    var endWorkoutButton: some View {
        Button {
            viewModel.alert = AppAlert(
                title: "Finish Workout",
                message: "If you haven't recorded a log for a movement it will be marked as skipped.",
                confirmAction: { Task { await viewModel.attemptEndCurrentWorkout() } },
                confirmLabel: "Save Workout",
                cancelLabel: "Cancel",
                destructiveAction: { Task { await viewModel.attemptDeleteCurrentWorkout() } },
                destructiveLabel: "Discard Workout"
            )
        } label: {
            Label("Finish", systemImage: "flag.pattern.checkered")
                .font(.headline)
        }
        .padding()
        .background(.ultraThinMaterial)
        .foregroundStyle(Color.accentColor)
        .clipShape(RoundedRectangle(cornerRadius: 25))
    }

    var timerView: some View {
        HStack(alignment: .bottom) {
            Text(timeElapsed)
                .font(.largeTitle)
                .onReceive(timer) { _ in
                    let interval = Date.now.timeIntervalSince(viewModel.currentWorkout?.start_timestamp ?? Date.now)

                    let totalMinutes = Int(interval / 60)
                    let hours = totalMinutes / 60
                    let minutes = totalMinutes % 60

                    if hours > 0 {
                        timeElapsed = "\(hours)h \(minutes)m"
                    } else {
                        timeElapsed = "\(minutes)m"
                    }
                }
            Text("elapsed")
                .font(.caption)
                .fontWeight(.semibold)
                .textCase(.uppercase)
                .padding(.bottom, 6)
        }
        .padding(EdgeInsets(top: 8, leading: 18, bottom: 8, trailing: 18))
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 25))
    }

    var currentWorkoutView: some View {
        ZStack {
            VStack {
                ScrollView {
                    // hidden timerView so that it doesn't cover the scrollable items below it.
                    timerView
                        .padding(.top, 10)
                        .padding(.bottom, 20)
                        .hidden()
                    ForEach(viewModel.currentWorkout?.movements_details ?? [], id: \.self) { movement in
                        CurrentWorkoutMovementView(movement: movement)
                    }
                    // placeholder list item so that the view is already at the correct width.
                    CurrentWorkoutMovementView(
                        movement: Movement(
                            name: "",
                            category: "",
                            notes: "",
                            recommended_warmup_sets: "",
                            recommended_working_sets: "",
                            recommended_rep_range: "",
                            recommended_rpe: ""))
                    .hidden()
                    Spacer().frame(height: 50)
                }
                .scrollIndicators(.hidden)
            }
            .padding(.horizontal, 16)
            VStack {
                timerView
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                Spacer()
            }
            HStack {
                Spacer().frame(width: 25)
                VStack {
                    Spacer()
                    addMovementButton
                    Spacer().frame(height: 20)
                }
                Spacer()
                VStack {
                    Spacer()
                    endWorkoutButton
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
                            if let newMovement = await viewModel.attemptQuickAddMovement(
                                movementName: formattedSearchText) {
                                if let _ = viewModel.currentWorkout {
                                    await viewModel.addMovementToCurrentWorkout(movementId: newMovement.id!)
                                } else {
                                    await viewModel.createWorkoutWithInitialMovement(movementId: newMovement.id!)
                                }
                                await viewModel.attemptGetCurrentWorkout()
                            }
                            dismissAddMovementOverlay()
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
                    .listRowBackground(Color.clear)
                }
            }
            .listSectionSpacing(.compact)
            Section {
                ForEach(Array(movementSearchResults), id: \.self) { (movement: Movement) in
                    Button {
                        Task {
                            if let movementIds = self.viewModel.currentWorkout?.movements_details?.map({ $0.id }),
                               movementIds.contains(movement.id) {
                                return
                            }
                            if let _ = viewModel.currentWorkout {
                                await viewModel.addMovementToCurrentWorkout(movementId: movement.id!)
                            } else {
                                await viewModel.createWorkoutWithInitialMovement(movementId: movement.id!)
                            }
                            await viewModel.attemptGetCurrentWorkout()
                            dismissAddMovementOverlay()
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
                    .listRowBackground(Color.clear)
                }
            }
            .listSectionSpacing(.compact)
        }
        .listStyle(.inset)
        .scrollContentBackground(.hidden)
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
        return viewModel.searchText.trimmingCharacters(in: CharacterSet(charactersIn: " ")).capitalized
    }

    var addMovementView : some View {
        VStack {
            addMovementSearchFieldView
            if viewModel.searchText.isEmpty {
                Spacer()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onEnded { value in
                            if value.translation.height > 0 {
                                dismissAddMovementOverlay()
                            }
                        }
                )

            } else {
                movementSearchResultsList
            }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.brandBackground.ignoresSafeArea()

                currentWorkoutView
                    .opacity(viewModel.currentWorkout != nil ? 1 : 0)
                ProgressView()
                    .opacity(viewModel.currentWorkout == nil && viewModel.isLoading(.currentWorkout) ? 1 : 0)

                if viewModel.currentWorkout == nil && !viewModel.isLoading(.currentWorkout) {
                    newWorkoutOptionsView
                        .transition(
                            .asymmetric(
                                insertion: .opacity.animation(.easeIn(duration: 0.2)),
                                removal: .opacity.animation(.easeOut(duration: 0))
                            )
                        )
                }

                if viewModel.showAddMovementOverlay {
                    addMovementView
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .background(.ultraThinMaterial.opacity(viewModel.showAddMovementOverlay ? 1 : 0))
                }
            }
            .animation(.default, value: viewModel.currentWorkout)
            .animation(.spring(duration: 0.3, bounce: 0.05), value: viewModel.showAddMovementOverlay)
            .task(id: appEnvironment.isNotAuthenticated) {
                guard !appEnvironment.isNotAuthenticated else { return }
                await viewModel.attemptGetCurrentWorkout()
                await viewModel.attemptGetMovements()
            }
            .sheet(isPresented: $viewModel.showCreateWorkoutSheet, onDismiss: {
                Task {
                    await viewModel.attemptGetCurrentWorkout()
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
            .navigationDestination(item: $viewModel.destination) { dest in
                switch dest {
                case .settings:
                    SettingsView()
                case .editWorkout:
                    MovementSelectorView(
                        viewModel: MovementSelectorView.ViewModel(workout: viewModel.currentWorkout)
                    )
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button {
                        viewModel.settingsTapped()
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    if viewModel.showAddMovementOverlay {
                        Button("Dismiss") {
                            dismissAddMovementOverlay()
                        }
                    } else if viewModel.currentWorkout != nil {
                        Menu {
                            Button {
                                viewModel.editWorkoutTapped()
                            } label: {
                                Label("Edit workout", systemImage: "pencil.circle")
                            }

                            Button(role: .destructive) {
                                viewModel.alert = AppAlert(
                                    title: "Cancel Workout",
                                    confirmAction: { Task { await viewModel.attemptDeleteCurrentWorkout() } },
                                    confirmLabel: "Yes",
                                    cancelLabel: "No"
                                )
                            } label: {
                                Label("Cancel workout", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
            .alert(item: $viewModel.alert)
        }
    }
}


#if DEBUG
#Preview("Active Workout") {
    NavigationStack {
        CurrentWorkoutView(viewModel: CurrentWorkoutView.ViewModel(
            workoutAPI: MockWorkoutAPI(),
            movementAPI: MockMovementAPI()))
    }
    .environmentObject(LumberjackedAppEnvironment())
}

#Preview("No Workout Yet") {
    NavigationStack {
        CurrentWorkoutView(viewModel: CurrentWorkoutView.ViewModel(
            workoutAPI: MockWorkoutAPI(currentWorkout: nil),
            movementAPI: MockMovementAPI()))
    }
    .environmentObject(LumberjackedAppEnvironment())
}
#endif
