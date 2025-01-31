//
//  CreateWorkoutMovementSelectorView.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/30/25.
//

import SwiftUI

struct CreateWorkoutMovementSelectorView: View {
    var templateWorkout: Workout?
    
    var body: some View {
        Text("CreateWorkoutMovementSelectorView!")
        Text("Selected \(templateWorkout?.id?.description ?? "none")!")
    }
}

#Preview {
    CreateWorkoutMovementSelectorView()
}
