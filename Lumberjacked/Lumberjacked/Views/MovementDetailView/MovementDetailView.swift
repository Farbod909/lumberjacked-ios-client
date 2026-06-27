//
//  MovementDetailView.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/22/25.
//

import SwiftUI

// MARK: - Adding unsaved-changes protection to this view
//
// When inline editing is added here, wire it up in three steps:
//
// 1. Add `isDirty: Bool` and `resetChanges()` to MovementDetailView.ViewModel
//    (see WorkoutDetailView.ViewModel for the pattern).
//
// 2. Apply the modifier once on the body's root view:
//       .unsavedChangesGuard(
//           isDirty: viewModel.isDirty,
//           save:    { await viewModel.attemptSaveChanges() },
//           discard: { viewModel.resetChanges() }
//       )
//
// 3. Add `.environment(UnsavedChangesState())` to any #Previews for this view.
//
// That's all — the custom back button, swipe-back interception, tab-switch alert,
// and the "you forgot to save" background notification are all handled automatically.

struct MovementDetailView: View {
    @State var viewModel: ViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color.brandBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(viewModel.movement.name)
                        .font(DesignSystem.Font.screenTitle)
                        .padding(.horizontal, 6)

                    if !viewModel.movement.hasNotes {
                        HStack {
                            Text("\(Image(systemName: "info.circle")) Edit this movement to add notes to help you during your workouts.")
                            Spacer()
                        }
                        .padding()
                        .brandCard()
                    }

                    if viewModel.movement.hasNotes {
                        NotesView(notes: viewModel.movement.notes)
                    }

                    if !viewModel.movementLogs.isEmpty {
                        LogListView(movementLogs: viewModel.movementLogs, onLogTap: viewModel.logTapped)

                        if viewModel.nextURL != nil || viewModel.isLoadingMore {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .onAppear {
                                    Task { await viewModel.attemptLoadMore() }
                                }
                        }
                    } else {
                        if viewModel.isLoading(.logs) {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding(.top, 40)
                        } else {
                            HStack {
                                Text("\(Image(systemName: "info.circle")) Add this movement to a new workout to keep track of log history.")
                                Spacer()
                            }
                            .padding()
                            .brandCard()
                        }
                    }
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 20)
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
                        viewModel: {
                            let vm = MovementLogInputView.ViewModel(
                                movementLog: log,
                                movement: viewModel.movement,
                                workout: nil)
                            vm.onSave = { viewModel.logSaved($0) }
                            vm.onDelete = { viewModel.logDeleted($0) }
                            return vm
                        }())
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
        }
    }
}

struct NotesView: View {
    let notes: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Notes")
                .sectionLabel()
            Text(notes)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .brandCard()
    }
}

struct LogListView: View {
    var movementLogs: [MovementLog]
    var onLogTap: (MovementLog) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Log History")
                .sectionLabel()
                .padding(.bottom, 8)
                .padding(.horizontal, 6)

            VStack(spacing: 0) {
                ForEach(Array(movementLogs.enumerated()), id: \.element) { index, log in
                    LogItem(movementLog: log, onTap: onLogTap)
                    if index < movementLogs.count - 1 {
                        Divider().padding(.leading, 16)
                    }
                }
            }
            .brandCard()
        }
    }
}

struct LogItem: View {
    let movementLog: MovementLog
    let onTap: (MovementLog) -> Void
    @AppStorage("weightUnit") private var weightUnitRaw: String = WeightUnit.lb.rawValue

    private var weightUnit: WeightUnit { WeightUnit(rawValue: weightUnitRaw) ?? .lb }

    var body: some View {
        Button {
            onTap(movementLog)
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    if let timestamp = movementLog.timestamp {
                        Text(timestamp.formatted(date: .abbreviated, time: .omitted))
                            .font(DesignSystem.Font.body)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.tertiary)
                }

                let displaySets = (movementLog.sets ?? []).filter { $0.type != "warmup" }
                if !displaySets.isEmpty {
                    FlowLayout(spacing: 6) {
                        ForEach(displaySets.indices, id: \.self) { i in
                            Text(chipLabel(displaySets[i]))
                                .font(DesignSystem.Font.body)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.brandSecondaryLight)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .foregroundStyle(.primary)
    }

    private func chipLabel(_ set: LogSet) -> String {
        if let load = set.load {
            let displayValue = weightUnit.fromLb(load)
            let rounded = (displayValue * 10).rounded() / 10
            let loadStr = rounded.truncatingRemainder(dividingBy: 1) == 0
                ? String(Int(rounded))
                : String(format: "%.1f", rounded)
            return "\(set.reps) × \(loadStr) \(weightUnit.unitLabel)"
        }
        return "\(set.reps)"
    }
}

private struct FlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        let rows = computeRows(maxWidth: proposal.width ?? .infinity, subviews: subviews)
        let height = rows.reduce(0) { $0 + $1.height } + spacing * CGFloat(max(0, rows.count - 1))
        return CGSize(width: proposal.width ?? 0, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        let rows = computeRows(maxWidth: bounds.width, subviews: subviews)
        var y = bounds.minY
        for row in rows {
            var x = bounds.minX
            for item in row.items {
                item.subview.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
                x += item.width + spacing
            }
            y += row.height + spacing
        }
    }

    private struct Row {
        var items: [(subview: LayoutSubview, width: CGFloat)]
        var height: CGFloat
    }

    private func computeRows(maxWidth: CGFloat, subviews: Subviews) -> [Row] {
        var rows: [Row] = []
        var current = Row(items: [], height: 0)
        var currentX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth && !current.items.isEmpty {
                rows.append(current)
                current = Row(items: [], height: 0)
                currentX = 0
            }
            current.items.append((subview: subview, width: size.width))
            current.height = max(current.height, size.height)
            currentX += size.width + spacing
        }

        if !current.items.isEmpty { rows.append(current) }
        return rows
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
