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
        vm.allMovements = PreviewData.movements
        vm.selectedMovements = [PreviewData.benchPress, PreviewData.squat]
        return vm
    }

    static var previewEditing: MovementSelectorView.ViewModel {
        let vm = MovementSelectorView.ViewModel(workout: PreviewData.pastWorkout_today)
        vm.isLoading = false
        vm.allMovements = PreviewData.movements
        return vm
    }
}

#Preview("New Workout") {
    NavigationStack {
        MovementSelectorView(viewModel: .preview)
    }
}

#Preview("Edit Existing Workout") {
    NavigationStack {
        MovementSelectorView(viewModel: .previewEditing)
    }
}
#endif
