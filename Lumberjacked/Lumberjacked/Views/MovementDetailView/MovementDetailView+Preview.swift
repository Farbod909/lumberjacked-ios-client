//
//  MovementDetailView+Preview.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 9/21/25.
//

#if DEBUG
import SwiftUI

struct MovementDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MovementDetailView(
                viewModel: sampleViewModel
            )
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Sample Data

    static var sampleMovement: Movement {
        Movement(
            id: 1,
            author: 123,
            name: "Bench Press",
            category: "",
            notes: "",
            created_timestamp: .now,
            updated_timestamp: .now,
            recommended_warmup_sets: "",
            recommended_working_sets: "",
            recommended_rep_range: "",
            recommended_rpe: "",
        )
    }

    static var sampleLogs: [MovementLog] {
        [
            MovementLog(
                id: 1,
                movement: 1,
                workout: 101,
                reps: [6,6,6,6],
                loads: [225,225,225,225],
                notes: "Felt strong today",
                timestamp: Calendar.current.date(byAdding: .day, value: -1, to: .now)
            ),
            MovementLog(
                id: 2,
                movement: 1,
                workout: 99,
                reps: [5,5,5,5],
                loads: [215,215,215,215],
                notes: "Last set was tough",
                timestamp: Calendar.current.date(byAdding: .day, value: -7, to: .now)
            ),
            MovementLog(
                id: 3,
                movement: 1,
                workout: 98,
                reps: [6,5,5],
                loads: [210,215,220],
                notes: "Mixed reps/loads",
                timestamp: Calendar.current.date(byAdding: .day, value: -14, to: .now)
            )
        ]
    }

    static var sampleViewModel: MovementDetailView.ViewModel {
        // Make sure your ViewModel can accept pre-populated logs
        let vm = MovementDetailView.ViewModel(movement: sampleMovement)
        vm.movementLogs = sampleLogs
        return vm
    }
}
#endif
