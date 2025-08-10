//
//  MovementInputView-ViewModel.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/22/25.
//

import SwiftUI

extension MovementInputView {
    @Observable
    class ViewModel {
        var movement: Movement
        var saveActionLoading = false
        
        init(movement: Movement) {
            self.movement = movement
        }
                
        @MainActor
        func attemptSaveNewMovement(errors: Binding<LumberjackedClientErrors>, dismissAction: () -> Void) async -> Movement? {
            saveActionLoading = true
            if let movement = await LumberjackedClient(errors: errors)
                .createMovement(movement: movement) {
                dismissAction()
                return movement
            }
            saveActionLoading = false
            return nil
        }
        
        @MainActor
        func attemptUpdateMovement(errors: Binding<LumberjackedClientErrors>, dismissAction: () -> Void) async {
            guard let movementId = movement.id else {
                print("No Movement ID")
                return
            }
            saveActionLoading = true
            if let _ = await LumberjackedClient(errors: errors)
                .updateMovement(movementId: movementId, movement: movement) {
                dismissAction()
            }
            saveActionLoading = false
        }
    }
}
