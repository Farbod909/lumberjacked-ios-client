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
    @Environment(RestTimerEnvironment.self) private var restTimer
    @FocusState var addMovementTextFieldFocusState: Bool

    // Movement drag-to-reorder state
    @State private var isReordering = false
    @State private var reorderDraggingIndex: Int? = nil
    @State private var reorderDragStartIndex: Int = 0
    private let reorderRowHeight: CGFloat = 52

    @State private var replacingMovementId: UInt64? = nil
    @State private var isKeyboardVisible = false
    @State private var showRestTimerPicker = false
    @State private var showRestTimerOptions = false
    @State private var pickerMinutes: Int = 2
    @State private var pickerSeconds: Int = 0

    init(viewModel: ViewModel = ViewModel()) {
        _viewModel = State(initialValue: viewModel)
    }

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    func dismissAddMovementOverlay() {
        addMovementTextFieldFocusState = false
        viewModel.showAddMovementOverlay = false
        viewModel.searchText = ""
        replacingMovementId = nil
    }

    // MARK: - Floating buttons

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

    // MARK: - Timer chip

    var elapsedText: some View {
        Text("\(timeElapsed) elapsed")
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .onReceive(timer) { _ in
                let interval = Date.now.timeIntervalSince(
                    viewModel.currentWorkout?.start_timestamp ?? Date.now)
                let totalMinutes = Int(interval / 60)
                let hours = totalMinutes / 60
                let minutes = totalMinutes % 60
                timeElapsed = hours > 0 ? "\(hours)h \(minutes)m" : "\(minutes)m"
            }
    }

    var restTimerButton: some View {
        let isActive = restTimer.isRunning || restTimer.showingZero
        return Button {
            guard !restTimer.showingZero else { return }
            if restTimer.isRunning {
                showRestTimerOptions = true
            } else {
                if restTimer.totalTime > 0 {
                    pickerMinutes = restTimer.totalTime / 60
                    pickerSeconds = (restTimer.totalTime % 60 / 10) * 10
                }
                showRestTimerPicker = true
            }
        } label: {
            Group {
                if isActive {
                    Text(restTimer.formattedTimeRemaining)
                        .font(.subheadline.monospacedDigit())
                        .foregroundStyle(Color.accentColor)
                        .contentTransition(.numericText(countsDown: true))
                        .animation(.default, value: restTimer.timeRemaining)
                } else {
                    Image(systemName: "timer")
                        .font(.body)
                        .foregroundStyle(Color.brandPrimaryText)
                }
            }
        }
        .popover(isPresented: $showRestTimerPicker) {
            restTimerPickerContent
        }
        .popover(isPresented: $showRestTimerOptions) {
            restTimerOptionsContent
        }
    }

    var restTimerPickerContent: some View {
        VStack(spacing: 12) {
            HStack(spacing: 0) {
                Picker("Minutes", selection: $pickerMinutes) {
                    ForEach(0...10, id: \.self) { Text("\($0)m") }
                }
                .pickerStyle(.wheel)
                .frame(width: 100)
                .clipped()

                Picker("Seconds", selection: $pickerSeconds) {
                    ForEach([0, 10, 20, 30, 40, 50], id: \.self) { Text("\($0)s") }
                }
                .pickerStyle(.wheel)
                .frame(width: 100)
                .clipped()
            }

            Button("Start") {
                let total = pickerMinutes * 60 + pickerSeconds
                if total > 0 {
                    restTimer.start(seconds: total, setId: UUID())
                }
                showRestTimerPicker = false
            }
            .buttonStyle(.borderedProminent)
            .disabled(pickerMinutes == 0 && pickerSeconds == 0)
            .padding(.bottom, 8)
        }
        .padding(.top, 8)
        .presentationCompactAdaptation(.popover)
    }

    var restTimerOptionsContent: some View {
        VStack(spacing: 0) {
            Button {
                restTimer.cancel()
                showRestTimerOptions = false
            } label: {
                Label("Stop", systemImage: "stop.fill")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            .foregroundStyle(.red)

            Divider()

            Button {
                restTimer.start(seconds: restTimer.totalTime, setId: UUID())
                showRestTimerOptions = false
            } label: {
                Label("Reset", systemImage: "arrow.counterclockwise")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            .foregroundStyle(.primary)
        }
        .frame(minWidth: 180)
        .presentationCompactAdaptation(.popover)
    }

    // MARK: - New workout options

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

    // MARK: - Active workout view

    var currentWorkoutView: some View {
        ZStack {
            VStack {
                ScrollView {
                    if isReordering {
                        // Compact name-only rows for drag-to-reorder
                        VStack(spacing: 8) {
                            ForEach(
                                Array(viewModel.editableEntries.enumerated()),
                                id: \.element.id
                            ) { index, entry in
                                compactReorderRow(entry, index: index)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    } else {
                        ForEach($viewModel.editableEntries) { $entry in
                            InlineMovementLogView(
                                movement: entry.movement,
                                movementNotes: $entry.movementNotes,
                                logNotes: $entry.logNotes,
                                logSets: $entry.logSets,
                                mode: .activeWorkout(
                                    previousSets: entry.movement.latest_log?.sets),
                                movementNotesEditable: true,
                                onReorderTapped: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        isReordering = true
                                    }
                                },
                                onReplaceTapped: {
                                    replacingMovementId = entry.movement.id
                                    viewModel.showAddMovementOverlay = true
                                },
                                onRemoveTapped: {
                                    if let id = entry.movement.id {
                                        Task { await viewModel.attemptRemoveMovement(movementId: id) }
                                    }
                                }
                            )
                        }
                    }

                    Spacer().frame(height: 80)
                }
                .scrollIndicators(.hidden)
            }

            if isKeyboardVisible {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            UIApplication.shared.sendAction(
                                #selector(UIResponder.resignFirstResponder),
                                to: nil, from: nil, for: nil)
                        } label: {
                            Image(systemName: "keyboard.chevron.compact.down")
                                .font(.title2)
                                .padding(12)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .foregroundStyle(Color.brandPrimaryText)
                        .padding(.trailing, 20)
                        .padding(.bottom, 12)
                    }
                }
            } else {
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
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            isKeyboardVisible = true
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            isKeyboardVisible = false
        }
    }

    // MARK: - Compact reorder row

    private func compactReorderRow(
        _ entry: EditableMovementEntry, index: Int
    ) -> some View {
        HStack(spacing: 12) {
            Text(entry.movement.name)
                .font(.headline)
                .foregroundStyle(.primary)
            Spacer()
            Image(systemName: "line.3.horizontal")
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(
            color: .black.opacity(reorderDraggingIndex == index ? 0.18 : 0),
            radius: 6, y: 3
        )
        .gesture(
            DragGesture(minimumDistance: 5, coordinateSpace: .global)
                .onChanged { value in
                    if reorderDraggingIndex == nil {
                        reorderDraggingIndex = index
                        reorderDragStartIndex = index
                    }
                    performMovementReorder(offset: value.translation.height)
                }
                .onEnded { _ in
                    reorderDraggingIndex = nil
                }
        )
    }

    private func performMovementReorder(offset: CGFloat) {
        guard let curIdx = reorderDraggingIndex else { return }
        let steps = Int((offset / reorderRowHeight).rounded())
        let targetIdx = max(
            0,
            min(viewModel.editableEntries.count - 1, reorderDragStartIndex + steps)
        )
        guard targetIdx != curIdx else { return }
        withAnimation(.easeInOut(duration: 0.15)) {
            viewModel.editableEntries.move(
                fromOffsets: IndexSet(integer: curIdx),
                toOffset: targetIdx > curIdx ? targetIdx + 1 : targetIdx
            )
        }
        reorderDraggingIndex = targetIdx
    }

    // MARK: - Add movement overlay

    var addMovementSearchFieldView: some View {
        HStack {
            TextField(
                "",
                text: $viewModel.searchText,
                prompt: Text(replacingMovementId != nil ? "Replace with..." : "Enter movement name...")
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
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.brandSecondary))
        .padding(.horizontal, 16)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    var movementSearchResultsList: some View {
        let currentIds = Set(viewModel.editableEntries.compactMap { $0.movement.id })
        let isReplaceable = replacingMovementId != nil
        return List {
            Section {
                if !viewModel.searchText.isEmpty {
                    Button {
                        Task {
                            if let newMovement = await viewModel.attemptQuickAddMovement(
                                movementName: formattedSearchText) {
                                if isReplaceable {
                                    if let oldId = replacingMovementId, let newId = newMovement.id {
                                        await viewModel.replaceMovement(oldId: oldId, newId: newId)
                                    }
                                } else if let _ = viewModel.currentWorkout {
                                    await viewModel.addMovementToCurrentWorkout(
                                        movementId: newMovement.id!)
                                } else {
                                    await viewModel.createWorkoutWithInitialMovement(
                                        movementId: newMovement.id!)
                                }
                                await viewModel.attemptGetCurrentWorkout()
                            }
                            dismissAddMovementOverlay()
                        }
                    } label: {
                        VStack(alignment: .leading) {
                            Label(
                                "Quick Add \"\(formattedSearchText)\"",
                                systemImage: "plus"
                            )
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
                    let alreadyAdded = currentIds.contains(movement.id ?? 0)
                    Button {
                        Task {
                            if alreadyAdded { return }
                            if isReplaceable {
                                if let oldId = replacingMovementId, let newId = movement.id {
                                    await viewModel.replaceMovement(oldId: oldId, newId: newId)
                                }
                                dismissAddMovementOverlay()
                            } else {
                                if let _ = viewModel.currentWorkout {
                                    await viewModel.addMovementToCurrentWorkout(
                                        movementId: movement.id!)
                                } else {
                                    await viewModel.createWorkoutWithInitialMovement(
                                        movementId: movement.id!)
                                }
                                await viewModel.attemptGetCurrentWorkout()
                                dismissAddMovementOverlay()
                            }
                        }
                    } label: {
                        HStack {
                            Text(movement.name)
                            Spacer()
                            if alreadyAdded {
                                Text("Added").font(.caption2).textCase(.uppercase)
                            }
                        }
                    }
                    .foregroundColor(alreadyAdded ? .secondary : .primary)
                    .listRowBackground(Color.clear)
                }
            }
            .listSectionSpacing(.compact)
        }
        .listStyle(.inset)
        .scrollContentBackground(.hidden)
    }

    var movementSearchResults: [Movement] {
        viewModel.searchText.isEmpty ? [] : viewModel.allMovements.filter {
            $0.name.lowercased().contains(viewModel.searchText.lowercased())
        }
    }

    var formattedSearchText: String {
        viewModel.searchText.trimmingCharacters(in: .whitespaces).capitalized
    }

    var addMovementView: some View {
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

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                Color.brandBackground.ignoresSafeArea()

                currentWorkoutView
                    .opacity(viewModel.currentWorkout != nil ? 1 : 0)
                ProgressView()
                    .opacity(
                        viewModel.currentWorkout == nil && viewModel.isLoading(.currentWorkout)
                            ? 1 : 0
                    )

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
                        .background(
                            .ultraThinMaterial.opacity(
                                viewModel.showAddMovementOverlay ? 1 : 0))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .animation(.default, value: viewModel.currentWorkout)
            .animation(
                .spring(duration: 0.3, bounce: 0.05),
                value: viewModel.showAddMovementOverlay
            )
            .task(id: appEnvironment.isNotAuthenticated) {
                guard !appEnvironment.isNotAuthenticated else { return }
                await viewModel.attemptGetCurrentWorkout()
                await viewModel.attemptGetMovements()
            }
            .sheet(
                isPresented: $viewModel.showCreateWorkoutSheet,
                onDismiss: { Task { await viewModel.attemptGetCurrentWorkout() } }
            ) {
                CreateWorkoutView()
            }
            .navigationDestination(for: Movement.self) { movement in
                MovementDetailView(
                    viewModel: MovementDetailView.ViewModel(movement: movement))
            }
            .navigationDestination(item: $viewModel.destination) { dest in
                switch dest {
                case .editWorkout:
                    MovementSelectorView(
                        viewModel: MovementSelectorView.ViewModel(
                            workout: viewModel.currentWorkout))
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    if viewModel.currentWorkout != nil {
                        restTimerButton
                    }
                }
                ToolbarItem(placement: .principal) {
                    if viewModel.currentWorkout != nil {
                        elapsedText
                    }
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    if isReordering {
                        Button("Done") {
                            withAnimation(.easeInOut(duration: 0.2)) { isReordering = false }
                            Task { await viewModel.persistMovementOrder() }
                        }
                        .fontWeight(.semibold)
                    } else if viewModel.showAddMovementOverlay {
                        Button("Dismiss") { dismissAddMovementOverlay() }
                    } else if viewModel.currentWorkout != nil {
                        Menu {
                            Button(role: .destructive) {
                                viewModel.alert = AppAlert(
                                    title: "Cancel Workout",
                                    confirmAction: {
                                        Task { await viewModel.attemptDeleteCurrentWorkout() }
                                    },
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
    .environment(RestTimerEnvironment())
}

#Preview("No Workout Yet") {
    NavigationStack {
        CurrentWorkoutView(viewModel: CurrentWorkoutView.ViewModel(
            workoutAPI: MockWorkoutAPI(currentWorkout: nil),
            movementAPI: MockMovementAPI()))
    }
    .environmentObject(LumberjackedAppEnvironment())
    .environment(RestTimerEnvironment())
}
#endif
