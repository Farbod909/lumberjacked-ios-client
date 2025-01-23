//
//  CurrentWorkoutView.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/21/25.
//

import SwiftUI

struct CurrentWorkoutView: View {
    @State var viewModel = ViewModel()
    
    var body: some View {
        Text("Current Workout!")
    }
}

#Preview {
    CurrentWorkoutView()
}
