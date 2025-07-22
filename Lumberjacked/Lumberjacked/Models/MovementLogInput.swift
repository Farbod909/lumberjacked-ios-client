//
//  MovementLogInput.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 7/13/25.
//

struct EqualSetsMovementLogInput {
    var sets: UInt16?
    var reps: UInt16?
    var load: Double?
    
    init(movementLog: MovementLog) {
        sets = UInt16(movementLog.reps?.count ?? 0)
        reps = movementLog.reps?.first ?? 0
        load = movementLog.loads?.first ?? 0.0
    }
}

struct CustomSetsMovementLogInput {
    var reps: [UInt16]?
    var loads: [Double]?
    
    init(movementLog: MovementLog) {
        reps = movementLog.reps
        loads = movementLog.loads
    }
}
