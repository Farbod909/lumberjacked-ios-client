//
//  MovementDetailView.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/22/25.
//

import SwiftUI

struct MovementDetailView: View {
    @State var viewModel: ViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color.brandBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 12) {
                Text(viewModel.movement.name)
                    .font(.title)
                    .fontWeight(.semibold)
                    .padding(EdgeInsets(top: 0, leading: 6, bottom: 0, trailing: 6))

                if !viewModel.movement.hasNotes {
                    HStack {
                        Text("\(Image(systemName: "info.circle")) Edit this movement to add notes to help you during your workouts.")
                        Spacer()
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 25).fill(Color.brandSecondary))
                }

                if viewModel.movement.hasNotes {
                    NotesView(notes: viewModel.movement.notes, maxHeight: 100)
                }

                if !viewModel.movementLogs.isEmpty {
                    LogListView(movementLogs: viewModel.movementLogs, onLogTap: viewModel.logTapped)
                } else {
                    if viewModel.isLoading(.logs) {
                        HStack {
                            Spacer()
                            VStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                            Spacer()
                        }
                    } else {
                        HStack {
                            Text("\(Image(systemName: "info.circle")) Add this movement to a new workout to keep track of log history.")
                            Spacer()
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 25).fill(Color.brandSecondary))
                    }
                }
                Spacer()
            }
            .task {
                await viewModel.attemptGetMovementLogs()
            }
            .toolbar {
                if viewModel.isLoading(.delete) {
                    ToolbarItem(placement: .topBarTrailing) {
                        ProgressView()
                    }
                }
                if viewModel.workout != nil {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            viewModel.newLogTapped()
                        } label: {
                            Label("New log", systemImage: "plus.square.fill")
                        }
                    }
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            viewModel.showEditSheet = true
                        } label: {
                            Label("Edit movement", systemImage: "pencil.circle")
                        }
                        Button(role: .destructive) {
                            viewModel.showDeleteConfirmationAlert = true
                        } label: {
                            Label("Delete movement", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .navigationDestination(item: $viewModel.destination) { dest in
                switch dest {
                case .editLog(let log):
                    MovementLogInputView(
                        viewModel: MovementLogInputView.ViewModel(
                            movementLog: log,
                            movement: viewModel.movement,
                            workout: nil))
                case .newLog:
                    MovementLogInputView(
                        viewModel: MovementLogInputView.ViewModel(
                            movementLog: MovementLog(notes: ""),
                            movement: viewModel.movement,
                            workout: viewModel.workout))
                }
            }
            .sheet(isPresented: $viewModel.showEditSheet, onDismiss: {
                Task {
                    if let movementId = viewModel.movement.id {
                        await viewModel.attemptGetMovementDetail(id: movementId)
                    }
                }
            }) {
                MovementInputView(
                    viewModel: MovementInputView.ViewModel(movement: viewModel.movement),
                    newlyAddedMovement: .constant(nil))
            }
            .alert("Delete", isPresented: $viewModel.showDeleteConfirmationAlert) {
                Button("Delete", role: .destructive) {
                    Task {
                        guard await viewModel.attemptDeleteMovement() else {
                            return
                        }
                        dismiss()
                    }
                }
                Button("Cancel", role: .cancel) {}
            }
            .padding(.horizontal, 10)
        }
    }
}

struct NotesView: View {
    let notes: String
    let maxHeight: CGFloat
    @State private var textHeight: CGFloat = .zero

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Notes")
                    .textCase(.uppercase)
                    .font(.headline)

                Group {
                    if textHeight > maxHeight {
                        ScrollView {
                            Text(notes)
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    GeometryReader { proxy in
                                        Color.clear
                                            .preference(key: HeightKey.self, value: proxy.size.height)
                                    }
                                )
                        }
                        .scrollIndicators(.hidden)
                        .frame(height: maxHeight)
                    } else {
                        Text(notes)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                GeometryReader { proxy in
                                    Color.clear
                                        .preference(key: HeightKey.self, value: proxy.size.height)
                                }
                            )
                    }
                }
            }
            Spacer()
        }
        .onPreferenceChange(HeightKey.self) { textHeight = $0 }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.brandSecondary)
        )
    }
}

private struct HeightKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

struct LogListView: View {
    var movementLogs: [MovementLog]
    var onLogTap: (MovementLog) -> Void

    var body: some View {
        VStack(alignment: .leading) {
            Text("Log History")
                .textCase(.uppercase)
                .font(.headline)
            List {
                ForEach(
                    movementLogs.sorted(
                        by: { $0.timestamp! > $1.timestamp! }
                    ),
                    id: \.self
                ) { log in
                    LogItem(movementLog: log, onTap: onLogTap)
                    .listRowInsets(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(.plain)
            .scrollIndicators(.hidden)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 25).fill(Color.brandSecondary))
    }
}

struct LogItem: View {
    let movementLog: MovementLog
    let onTap: (MovementLog) -> Void

    var body: some View {
        Button {
            onTap(movementLog)
        } label: {
            HStack(alignment: .top) {
                if let timestamp = movementLog.timestamp {
                    Text(timestamp.formatted(date: .abbreviated, time: .omitted))
                        .fontWeight(.semibold)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    ForEach(movementLog.summary, id:\.self) { item in
                        Text(item)
                    }
                }
                .textCase(.uppercase)
            }
        }
        .foregroundStyle(.primary)
    }
}

#if DEBUG
#Preview("Full Details with Logs") {
    NavigationStack {
        MovementDetailView(viewModel: MovementDetailView.ViewModel(
            movement: PreviewData.benchPress,
            movementLogAPI: MockMovementLogAPI()))
    }
}

#Preview("Minimal Details, No Logs") {
    let movement = Movement(id: 8, name: "Seated Cable Row", notes: "")
    return NavigationStack {
        MovementDetailView(viewModel: MovementDetailView.ViewModel(
            movement: movement,
            movementAPI: MockMovementAPI(),
            movementLogAPI: MockMovementLogAPI()))
    }
}

#Preview("Full Details, No Logs") {
    NavigationStack {
        MovementDetailView(viewModel: MovementDetailView.ViewModel(
            movement: PreviewData.deadlift,
            movementLogAPI: MockMovementLogAPI()))
    }
}
#endif
