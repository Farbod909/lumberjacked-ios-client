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
        guard let logSets = movementLog.sets, !logSets.isEmpty else {
            sets = nil
            reps = nil
            load = nil
            return
        }
        let allSameReps = logSets.allSatisfy { $0.reps == logSets[0].reps }
        let allSameLoad = logSets.allSatisfy { $0.load == logSets[0].load }
        if allSameReps && allSameLoad {
            self.sets = UInt16(logSets.count)
            self.reps = UInt16(logSets[0].reps)
            self.load = logSets[0].load ?? 0.0
        } else {
            self.sets = nil
            self.reps = nil
            self.load = nil
        }
    }
}

struct CustomSetsMovementLogInput {
    var sets: [LogSet]?

    init(movementLog: MovementLog) {
        sets = movementLog.sets
    }
}
