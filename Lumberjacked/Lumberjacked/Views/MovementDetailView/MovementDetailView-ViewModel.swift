//
//  MovementDetailView-ViewModel.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/22/25.
//

import SwiftUI

extension MovementDetailView {
    @Observable
    class ViewModel {
        var movement: Movement
        var movementLogs = [MovementLog]()
        var workout: Workout?
        var isLoadingMovementLogs = true
        var deleteActionLoading = false
        var showDeleteConfirmationAlert = false
        var showEditSheet = false
        
        init(movement: Movement, movementLogs: [MovementLog] = [MovementLog]()) {
            self.movement = movement
            self.movementLogs = movementLogs
        }
        
        func attemptGetMovementLogs(errors: Binding<LumberjackedClientErrors>) async {
            isLoadingMovementLogs = true
            if let response = await LumberjackedClient(errors: errors)
                .getMovementLogs(movementId: self.movement.id!) {
                movementLogs = response.results
            }
            isLoadingMovementLogs = false
        }
        
        func attemptDeleteMovement(id: UInt64, errors: Binding<LumberjackedClientErrors>) async -> Bool {
            deleteActionLoading = true
            let success = await LumberjackedClient(errors: errors)
                .deleteMovement(movementId: self.movement.id!)
            deleteActionLoading = false
            return success
        }
        
        func attemptGetMovementDetail(id: UInt64, errors: Binding<LumberjackedClientErrors>) async {
            if let response = await LumberjackedClient(errors: errors)
                .getMovement(movementId: id) {
                movement = response
            }
        }
    }
}
