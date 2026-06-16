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
    @FocusState private var searchFieldFocused: Bool

    func dismissAddMovementOverlay() {
        searchFieldFocused = false
        viewModel.showAddMovementOverlay = false
        viewModel.searchText = ""
    }

    // MARK: - Add movement overlay

    var addMovementSearchFieldView: some View {
        HStack {
            TextField(
                "",
                text: $viewModel.searchText,
                prompt: Text("Search movements...")
                    .foregroundStyle(.brandPrimaryText.opacity(0.6))
            )
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .keyboardType(.alphabet)
            .focused($searchFieldFocused)
            .foregroundStyle(Color.brandPrimaryText)
            .frame(height: 44)
            .padding(.horizontal, 16)

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

    var addMovementSearchResults: [Movement] {
        viewModel.searchText.isEmpty ? [] : viewModel.allMovements.filter {
            $0.name.lowercased().contains(viewModel.searchText.lowercased())
        }
    }

    var addMovementOverlay: some View {
        VStack(spacing: 0) {
            addMovementSearchFieldView
                .padding(.top, 8)

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
                let currentIds = Set(
                    viewModel.editableEntries.filter { !$0.isRemoved }.compactMap { $0.movement.id }
                )
                List {
                    ForEach(addMovementSearchResults, id: \.self) { movement in
                        let alreadyAdded = currentIds.contains(movement.id ?? 0)
                        Button {
                            if !alreadyAdded {
                                viewModel.addPendingMovement(movement)
                                dismissAddMovementOverlay()
                            }
                        } label: {
                            HStack {
                                Text(movement.name)
                                Spacer()
                                if alreadyAdded {
                                    Text("Added")
                                        .font(.caption2)
                                        .textCase(.uppercase)
                                }
                            }
                        }
                        .foregroundColor(alreadyAdded ? .secondary : .primary)
                        .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.inset)
                .scrollContentBackground(.hidden)
            }
        }
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.brandBackground.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 12) {
                Text(viewModel.workout.humanReadableStartTimestamp ?? "Unknown")
                    .font(.title)
                    .fontWeight(.semibold)
                    .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
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
                .padding(.horizontal, 16)
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach($viewModel.editableEntries) { $entry in
                            if entry.isRemoved {
                                HStack {
                                    Text(entry.movement.name)
                                        .font(.title2.bold())
                                        .strikethrough()
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    Button("Undo") {
                                        entry.isRemoved = false
                                    }
                                    .foregroundStyle(Color.accentColor)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                            } else {
                                InlineMovementLogView(
                                    movement: entry.movement,
                                    movementNotes: .constant(entry.movement.notes),
                                    logNotes: $entry.logNotes,
                                    logSets: $entry.logSets,
                                    mode: .editLog,
                                    movementNotesEditable: false,
                                    onRemoveTapped: {
                                        entry.isRemoved = true
                                    }
                                )
                            }
                        }
                        Spacer().frame(height: 80)
                    }
                }
                .scrollIndicators(.hidden)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if viewModel.showAddMovementOverlay {
                addMovementOverlay
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .background(.ultraThinMaterial.opacity(viewModel.showAddMovementOverlay ? 1 : 0))
            }
        }
        .animation(.spring(duration: 0.3, bounce: 0.05), value: viewModel.showAddMovementOverlay)
        .onChange(of: viewModel.showAddMovementOverlay) { _, isShowing in
            if isShowing {
                searchFieldFocused = true
            }
        }
        .task {
            await viewModel.attemptRefreshWorkout()
            await viewModel.attemptGetMovements()
        }
        .onDisappear {
            if viewModel.isDirty {
                Task { await viewModel.attemptSaveChanges() }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                if viewModel.showAddMovementOverlay {
                    Button("Dismiss") {
                        dismissAddMovementOverlay()
                    }
                } else {
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
                        Button {
                            viewModel.showAddMovementOverlay = true
                        } label: {
                            Label("Add movement", systemImage: "plus")
                        }
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
            movementLogAPI: MockMovementLogAPI(),
            movementAPI: MockMovementAPI()))
    }
    .environment(RestTimerEnvironment())
}

#Preview("Older Workout") {
    NavigationStack {
        WorkoutDetailView(viewModel: WorkoutDetailView.ViewModel(
            workout: PreviewData.pastWorkout_2weeksAgo,
            workoutAPI: MockWorkoutAPI(),
            movementLogAPI: MockMovementLogAPI(),
            movementAPI: MockMovementAPI()))
    }
    .environment(RestTimerEnvironment())
}
#endif
