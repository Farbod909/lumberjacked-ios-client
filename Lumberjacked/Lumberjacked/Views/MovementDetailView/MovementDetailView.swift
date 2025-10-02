//
//  MovementDetailView.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/22/25.
//

import SwiftUI

struct MovementDetailView: View {
    @State var viewModel: ViewModel
    @State var errors = LumberjackedClientErrors()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.brandBackground.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 12) {
                Text(viewModel.movement.name)
                    .font(.title)
                    .fontWeight(.semibold)
                    .padding(EdgeInsets(top: 0, leading: 6, bottom: 0, trailing: 6))
                if !viewModel.movement.hasNotes &&
                    !viewModel.movement.hasCategory &&
                    !viewModel.movement.hasAnyRecommendations {
                    HStack {
                        Text("\(Image(systemName: "info.circle")) Edit this movement to add useful information like notes or recommendations to help you during your workouts.")
                        Spacer()
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 25).fill(Color.brandSecondary))
                }
                
                if viewModel.movement.hasCategory {
                    HStack {
                        Text("category")
                            .textCase(.uppercase)
                            .font(.headline)
                        Text(viewModel.movement.category)
                            .foregroundColor(.primary)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 25).fill(Color.brandSecondary))
                }
                
                if viewModel.movement.hasNotes {
                    NotesView(notes: viewModel.movement.notes, maxHeight: 100)
                }
                
                if viewModel.movement.hasAnyRecommendations {
                    HStack {
                        RecommendationsView(movement: viewModel.movement)
                        Spacer()
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 25).fill(Color.brandSecondary))
                }
                
                if !viewModel.movementLogs.isEmpty {
                    LogListView(movementLogs: viewModel.movementLogs)
                } else {
                    if viewModel.isLoadingMovementLogs {
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
                await viewModel.attemptGetMovementLogs(errors: $errors)
            }
            .toolbar {
                if viewModel.deleteActionLoading {
                    ToolbarItem(placement: .topBarTrailing) {
                        ProgressView()
                    }
                }
                if viewModel.workout != nil {
                    ToolbarItem(placement: .primaryAction) {
                        NavigationLink() {
                            Text("new log page")
                        } label: {
                            Label("New log", systemImage: "plus.square.fill")
                        }
                    }
                }
                ToolbarItemGroup(placement: .secondaryAction) {
                    Button {
                        viewModel.showEditSheet = true
                    } label: {
                        Label("Edit movement", systemImage: "pencil.circle")
                    }
                    Button {
                        viewModel.showDeleteConfirmationAlert = true
                    } label: {
                        Label("Delete movement", systemImage: "trash")
                    }
                }
            }
            .navigationDestination(for: MovementLog.self) { movementLog in
                MovementLogInputView(
                    viewModel: MovementLogInputView.ViewModel(
                        movementLog: movementLog,
                        movement: viewModel.movement,
                        workout: nil))
            }
            .sheet(isPresented: $viewModel.showEditSheet, onDismiss: {
                Task {
                    if let movementId = viewModel.movement.id {
                        await viewModel.attemptGetMovementDetail(id: movementId, errors: $errors)
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
                        guard await viewModel.attemptDeleteMovement(id: viewModel.movement.id!, errors: $errors) else {
                            return
                        }
                        dismiss()
                    }
                }
                Button("Cancel", role: .cancel) {}
            }
            .padding(.horizontal, 6)
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

struct RecommendationsView: View {
    let movement: Movement
    
    struct Recommendation: Hashable, Equatable {
        let name: String
        let value: String
    }
    
    var recommendations: [Recommendation] {
        var result = [Recommendation]()
        if !movement.recommended_warmup_sets.isEmpty {
            result.append(Recommendation(name: "Warmup Sets", value: movement.recommended_warmup_sets))
        }
        if !movement.recommended_working_sets.isEmpty {
            result.append(Recommendation(name: "Working Sets", value: movement.recommended_working_sets))
        }
        if !movement.recommended_rep_range.isEmpty {
            result.append(Recommendation(name: "Rep Range", value: movement.recommended_rep_range))
        }
        if !movement.recommended_rpe.isEmpty {
            result.append(Recommendation(name: "RPE", value: movement.recommended_rpe))
        }
        if let restTime = movement.recommended_rest_time {
            let minutes: UInt16 = restTime / 60
            let seconds: UInt16 = restTime % 60
            var value = ""
            if minutes > 0 {
                value.append("\(minutes)m")
            }
            if seconds > 0 {
                value.append("\(seconds)s")
            }
            result.append(Recommendation(name: "Rest", value: value))
        }
        return result
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Recommendations")
                .textCase(.uppercase)
                .font(.headline)
            VStack(alignment: .leading, spacing: 0) {
                ForEach(recommendations, id: \.self) { recommendation in
                    HStack {
                        Text(recommendation.name)
                            .textCase(.uppercase)
                            .font(.subheadline)
                            .fontWidth(.condensed)
                            .fontWeight(.semibold)
                        Text(recommendation.value)
                    }
                    .padding(0)
                }
            }
            .foregroundColor(.primary)
        }
    }
}

struct LogListView: View {
    var movementLogs: [MovementLog]
    
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
                    LogItem(movementLog: log)
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
    
    var body: some View {
        NavigationLink(value: movementLog) {
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
    }
}

#if DEBUG
struct MovementDetailView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationStack {
                MovementDetailView(
                    viewModel: viewModelWithPopulatedMovementAndLogs
                )
            }
            .previewDisplayName("Full Details with Logs")
            NavigationStack {
                MovementDetailView(
                    viewModel: viewModelWithEmptyMovementNoLogs
                )
            }
            .previewDisplayName("Minimal Details, No Logs")
            NavigationStack {
                MovementDetailView(
                    viewModel: viewModelWithPopulatedMovementNoLogs
                )
            }
            .previewDisplayName("Full Details, No Logs")
        }
    }

    // MARK: - Sample Data

    // --- Mock Data ---
    static let sampleLog1 = MovementLog(
        id: 1, movement: 1, reps: [10, 10, 10], loads: [135, 135, 135], notes: "", timestamp: Date()
    )
    
    static let sampleLog2 = MovementLog(
        id: 2, movement: 1, reps: [8, 8, 6], loads: [145, 145, 145], notes: "", timestamp: Calendar.current.date(byAdding: .day, value: -7, to: Date())!
    )
    
    static let fullDetailMovement = Movement(
        id: 1,
        name: "Barbell Bench Press",
        category: "Chest",
        notes: "Keep elbows tucked at a 45-degree angle. Don't bounce the bar off the chest.",
        recommended_warmup_sets: "2-3",
        recommended_working_sets: "3",
        recommended_rep_range: "8-12",
        recommended_rpe: "7-8",
        recommended_rest_time: 90
    )
    
    static let noDetailMovement = Movement(
        id: 2,
        name: "Bodyweight Squat",
        category: "",
        notes: "",
        recommended_warmup_sets: "",
        recommended_working_sets: "",
        recommended_rep_range: "",
        recommended_rpe: ""
    )
    
    static let mockWorkout = Workout(id: 1)

    // --- View Models for Different States ---
    
    // 1. Full details with logs
    static let viewModelWithPopulatedMovementAndLogs: MovementDetailView.ViewModel = {
        let vm = MovementDetailView.ViewModel(movement: fullDetailMovement, movementLogs: [sampleLog1, sampleLog2])
        vm.isLoadingMovementLogs = false
        vm.workout = mockWorkout // Set workout to show the "New Log" button
        return vm
    }()

    // 2. Minimal details, no logs
    static let viewModelWithEmptyMovementNoLogs: MovementDetailView.ViewModel = {
        let vm = MovementDetailView.ViewModel(movement: noDetailMovement)
        return vm
    }()
    
    // 3. Full details, no logs
    static let viewModelWithPopulatedMovementNoLogs: MovementDetailView.ViewModel = {
        let vm = MovementDetailView.ViewModel(movement: fullDetailMovement)
        return vm
    }()
}
#endif
