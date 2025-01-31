//
//  MovementLog.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/29/25.
//

import Foundation

struct MovementLog: Codable, Hashable {
    var id: UInt64?
    var movement: UInt64?
    var workout: UInt64?
    var reps: [UInt16]?
    var loads: [Double]?
    var notes: String?
    var timestamp: Date?
    
    var for_current_workout: Bool?
    
    var setsAndRepsString: String {
        guard let reps = reps else {
            return ""
        }
        
        var repsAllEqual = true
        for (idx, r) in reps.enumerated() {
            if idx < reps.count - 1 {
                if r != reps[idx + 1] {
                    repsAllEqual = false
                    break
                }
            }
        }
        
        if repsAllEqual {
            return "\(reps.count) x \(reps[0])"
        } else {
            return reps.map { String($0) }.joined(separator: ", ")
        }
            
    }
}
