//
//  MovementSelectorView+Preview.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 9/21/25.
//

#if DEBUG
import SwiftUI

private extension MovementSelectorView.ViewModel {
    static var preview: MovementSelectorView.ViewModel {
        let vm = MovementSelectorView.ViewModel()
        vm.isLoading = false
        vm.allMovements = [
            Movement(
                id: 1,
                author: 1,
                name: "Bench Press",
                category: "Chest",
                notes: "Flat barbell bench",
                recommended_warmup_sets: "2",
                recommended_working_sets: "3",
                recommended_rep_range: "8-10",
                recommended_rpe: "7",
                recommended_rest_time: 120
            ),
            Movement(
                id: 2,
                author: 1,
                name: "Squat",
                category: "Legs",
                notes: "Back squat",
                recommended_warmup_sets: "2",
                recommended_working_sets: "4",
                recommended_rep_range: "5-8",
                recommended_rpe: "8",
                recommended_rest_time: 180
            ),
            Movement(
                id: 3,
                author: 1,
                name: "Deadlift",
                category: "Back",
                notes: "Conventional",
                recommended_warmup_sets: "2",
                recommended_working_sets: "3",
                recommended_rep_range: "5-8",
                recommended_rpe: "8",
                recommended_rest_time: 240
            )
        ]
        vm.selectedMovements = [vm.allMovements[0]]
        return vm
    }
}

#Preview {
    NavigationStack {
        MovementSelectorView(viewModel: .preview)
    }
}
#endif
