//
//  CreateWorkoutView.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/22/25.
//

import SwiftUI

struct CreateWorkoutView: View {
    @State var viewModel = ViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            TemplateWorkoutSelectorView(
                templateWorkout: $viewModel.templateWorkout,
                dismissAction: { dismiss() })
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    NavigationLink("Next") {
                        MovementSelectorView(
                            viewModel: MovementSelectorView.ViewModel(templateWorkout: viewModel.templateWorkout),
                            dismissAction: { dismiss() })
                    }
                }
            }
        }
    }
}

#Preview {
    CreateWorkoutView()
}
