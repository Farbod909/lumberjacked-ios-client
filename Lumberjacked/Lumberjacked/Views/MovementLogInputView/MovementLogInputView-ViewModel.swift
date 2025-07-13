//
//  MovementLogInputView-ViewModel.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/22/25.
//

import SwiftUI

extension MovementLogInputView {
    @Observable
    class ViewModel {
        
        var movementLog: MovementLog
        var movement: Movement
        
        var toolbarActionLoading = false
        
        init(
            movementLog: MovementLog,
            movement: Movement
        ) {
            self.movementLog = movementLog
            self.movement = movement
        }
        
        func attemptUpdateLog() async -> Bool {
            return false
        }
        
        func attemptSaveNewLog() async -> Bool {
            return false
        }
        
        func attemptDeleteLog() async -> Bool {
            return false
        }
        
        func formSubmit() async -> Bool {
            return false
        }
    }
}
