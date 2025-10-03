//
//  WorkoutDetailView.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/22/25.
//

import SwiftUI

struct WorkoutDetailView: View {
    @State var viewModel: ViewModel
    @State var errors = LumberjackedClientErrors()
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color.brandBackground.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 12) {
                Text(viewModel.workout.humanReadableStartTimestamp ?? "Unknown")
                    .font(.title)
                    .fontWeight(.semibold)
                    .padding(EdgeInsets(top: 0, leading: 6, bottom: 0, trailing: 6))
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
                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach(viewModel.workout.movements_details ?? [], id:\.self) { movement in
                            if let movementLog = movement.recorded_log {
                                NavigationLink(destination: MovementLogInputView(
                                    viewModel: MovementLogInputView.ViewModel(
                                        movementLog: movementLog,
                                        movement: movement,
                                        workout: viewModel.workout))) {
                                    HStack(alignment: .top) {
                                        VStack(alignment: .leading) {
                                            Text(movement.name)
                                                .multilineTextAlignment(.leading)
                                                .font(.headline)
                                            VStack {
                                                Spacer()
                                                Text(movementLog.notes)
                                                    .multilineTextAlignment(.leading)
                                                    .font(.subheadline)
                                                Spacer()
                                            }
                                        }
                                        Spacer()
                                        VStack(alignment: .trailing) {
                                            ForEach(movementLog.summary, id:\.self) { item in
                                                Text(item)
                                            }
                                        }
                                        .textCase(.uppercase)
                                    }
                                    .padding()
                                    .background(RoundedRectangle(cornerRadius: 25).fill(Color.brandSecondary))
                                }
                                .foregroundStyle(Color.brandPrimaryText)
                            }
                        }
                    }
                }
                .scrollIndicators(.hidden)

                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 10)
        }
//        .navigationDestination(for: MovementLogDestination.self) { movementLogDestination in
//            MovementLogInputView(
//                viewModel: MovementLogInputView.ViewModel(
//                    movementLog: movementLogDestination.log,
//                    movement: movementLogDestination.movement,
//                    workout: viewModel.workout))
//        }
    }
}

#if DEBUG
struct WorkoutDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            WorkoutDetailView(
                viewModel: previewViewModel
            )
        }
    }
    
    // MARK: - Sample Data
    
    // --- Mock Data ---
    
    static let movement1Log = MovementLog(
        id: 1, movement: 1, reps: [10, 10, 10], loads: [135, 135, 135], notes: "", timestamp: Calendar.current.date(byAdding: .hour, value: -3, to: Date())!
    )
    
    static let movement2Log = MovementLog(
        id: 2, movement: 2, reps: [6, 5, 4], loads: [145, 145, 150], notes: "Did not feel strong.", timestamp: Calendar.current.date(byAdding: .hour, value: -2, to: Date())!
    )
    
    static let movement3Log = MovementLog(
        id: 3, movement: 3, reps: [8, 8, 8], loads: [190, 190, 190], notes: "", timestamp: Calendar.current.date(byAdding: .hour, value: -1, to: Date())!
    )

    static let movement1 = Movement(
        id: 1,
        name: "Barbell Bench Press",
        category: "Chest",
        notes: "Keep elbows tucked at a 45-degree angle. Don't bounce the bar off the chest.",
        recommended_warmup_sets: "2-3",
        recommended_working_sets: "3",
        recommended_rep_range: "8-12",
        recommended_rpe: "7-8",
        recommended_rest_time: 90,
        recorded_log: movement1Log
    )
    
    static let movement2 = Movement(
        id: 2,
        name: "Barbell Squat",
        category: "Lower",
        notes: "Go as low as possible. Put plates under your heels if you need to.",
        recommended_warmup_sets: "2-3",
        recommended_working_sets: "1",
        recommended_rep_range: "4-6",
        recommended_rpe: "7-8",
        recommended_rest_time: 90,
        recorded_log: movement2Log
    )

    static let movement3 = Movement(
        id: 3,
        name: "Deadlift",
        category: "Core",
        notes: "Brace your core before going up. Do not round back.",
        recommended_warmup_sets: "1",
        recommended_working_sets: "2",
        recommended_rep_range: "6-8",
        recommended_rpe: "7-8",
        recommended_rest_time: 90,
        recorded_log: movement3Log
    )

    static let workout = Workout(
        id: 1,
        start_timestamp: Calendar.current.date(byAdding: .hour, value: -4, to: Date())!,
        end_timestamp: Date(),
        movements_details: [movement1, movement2, movement3])
    
    static let previewViewModel = WorkoutDetailView.ViewModel(workout: workout)
}
#endif
