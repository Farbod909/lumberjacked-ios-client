//
//  CurrentWorkoutView.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/21/25.
//

import SwiftUI

struct CurrentWorkoutView: View {
    @State var viewModel = ViewModel()
    @State var errors = LumberjackedClientErrors()
    @EnvironmentObject var appEnvironment: LumberjackedAppEnvironment
    
    var body: some View {
        VStack {
            if viewModel.currentWorkout == nil {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    Button {
                        viewModel.showCreateWorkoutSheet.toggle()
                    } label: {
                        Label("New workout", systemImage: "plus")
                    }
                }
            } else {
                Text(viewModel.currentWorkout.debugDescription)
                Button("End workout ") {
                    Task {
                        await viewModel.attemptEndCurrentWorkout(errors: $errors)
                    }
                }
            }
        }
        .task(id: appEnvironment.isNotAuthenticated) {
            await viewModel.attemptGetCurrentWorkout(errors: $errors)
        }
        .sheet(isPresented: $viewModel.showCreateWorkoutSheet, onDismiss: {
            Task {
                await viewModel.attemptGetCurrentWorkout(errors: $errors)
            }
        }) {
            CreateWorkoutView()
        }
    }
}

#Preview {
    CurrentWorkoutView()
}
