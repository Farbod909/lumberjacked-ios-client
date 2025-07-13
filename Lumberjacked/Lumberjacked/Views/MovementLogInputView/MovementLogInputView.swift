//
//  MovementLogInputView.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/22/25.
//

import SwiftUI

struct MovementLogInputView: View {
    @State var viewModel: ViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        if let reps = viewModel.movementLog.reps, !reps.isEmpty {
            Text("\(viewModel.movementLog.summary)")
        } else {
            Text("New log")
        }
    }
}
