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
}

extension MovementLog {
    /**
     *  Helper functions/properties for representing MovementLog data more easily in the UI.
     */
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
    
    var loadsString: String {
        func roundDouble(double: Double) -> String {
            let roundedValue = (double * 10).rounded() / 10
            if roundedValue.truncatingRemainder(dividingBy: 1) == 0 {
                return String(Int(roundedValue))
            } else {
                return String(format: "%.1f", roundedValue)
            }
        }
        
        guard let loads = loads else {
            return ""
        }
        
        var loadsAllEqual = true
        for (idx, l) in loads.enumerated() {
            if idx < loads.count - 1 {
                if l != loads[idx + 1] {
                    loadsAllEqual = false
                    break
                }
            }
        }
        
        if loadsAllEqual {
            return roundDouble(double: loads[0]) + " lb"
        } else {
            return loads.map { roundDouble(double: $0) + " lb" }.joined(separator: ", ")
        }
            
    }

}
