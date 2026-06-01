//
//  CreateWorkoutView.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/22/25.
//

import SwiftUI

struct CreateWorkoutView: View {
    @State var viewModel: ViewModel
    @Environment(\.dismiss) var dismiss

    init(viewModel: ViewModel = ViewModel()) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            TemplateWorkoutSelectorView(
                templateWorkout: $viewModel.templateWorkout,
                dismissAction: { dismiss() })
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    if viewModel.isLoadingToolbarAction {
                        ProgressView()
                    } else {
                        Button("Start Workout") {
                            Task {
                                await viewModel.attemptCreateWorkout(dismissAction: { dismiss() })
                            }
                        }
                        .disabled(viewModel.templateWorkout == nil)
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .interactiveDismissDisabled()
    }
}

#if DEBUG
#Preview {
    CreateWorkoutView(viewModel: CreateWorkoutView.ViewModel(api: MockWorkoutAPI()))
}
#endif
