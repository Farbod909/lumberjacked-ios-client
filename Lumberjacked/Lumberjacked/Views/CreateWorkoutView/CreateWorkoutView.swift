//
//  CreateWorkoutView.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/22/25.
//

import SwiftUI

struct CreateWorkoutView: View {
    @State var viewModel = ViewModel()
    
    var body: some View {
        NavigationStack {
            SelectTemplateWorkoutView(templateWorkout: $viewModel.templateWorkout)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    NavigationLink("Next") {
                        CreateWorkoutMovementSelectorView(
                            templateWorkout: viewModel.templateWorkout)
                    }
                }
            }
        }
    }
}

#Preview {
    CreateWorkoutView()
}
