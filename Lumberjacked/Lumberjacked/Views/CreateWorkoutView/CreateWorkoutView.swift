//
//  CreateWorkoutView.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/22/25.
//

import SwiftUI

struct CreateWorkoutView: View {
    @State var viewModel = ViewModel()
    @State var errors = LumberjackedClientErrors()
    @Environment(\.dismiss) var dismiss
    
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
                                await viewModel.attemptCreateWorkout(
                                    errors: $errors, dismissAction: { dismiss() })
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

#Preview {
    CreateWorkoutView()
}
