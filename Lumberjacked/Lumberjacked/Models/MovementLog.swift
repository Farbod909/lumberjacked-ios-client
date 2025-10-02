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
    var notes: String
    var timestamp: Date?
    
    var for_current_workout: Bool?
}

extension MovementLog {
    /**
     *  Helper functions/properties for representing MovementLog data more easily in the UI.
     */
    func roundDouble(_ double: Double) -> String {
        let roundedValue = (double * 10).rounded() / 10
        if roundedValue.truncatingRemainder(dividingBy: 1) == 0 {
            return String(Int(roundedValue))
        } else {
            return String(format: "%.1f", roundedValue)
        }
    }
    
    var repsAllEqual: Bool {
        guard let reps = reps else {
            return true
        }
        
        for (idx, r) in reps.enumerated() {
            if idx < reps.count - 1 {
                if r != reps[idx + 1] {
                    return false
                }
            }
        }
        return true
    }
    
    var loadsAllEqual: Bool {
        guard let loads = loads else {
            return true
        }
        for (idx, l) in loads.enumerated() {
            if idx < loads.count - 1 {
                if l != loads[idx + 1] {
                    return false
                }
            }
        }
        return true
    }

    var setsAndRepsString: String {
        guard let reps = reps else {
            return ""
        }
                
        if repsAllEqual {
            return "\(reps.count) × \(reps[0])"
        } else {
            return reps.map { String($0) }.joined(separator: ", ")
        }
            
    }
    
    var loadsString: String {
        guard let loads = loads else {
            return ""
        }
        
        if loadsAllEqual {
            return roundDouble(loads[0]) + "\u{FEFF} \u{FEFF}lb"
        } else {
            return loads.map { roundDouble($0) + "\u{FEFF} \u{FEFF}lb" }.joined(separator: ", ")
        }
    }
    
    var summary: [String] {
        /**
         * Return strings that represent a summary of the MovementLog.
         * If the reps and loads are all equal, each element is: X sets of, Y reps, Z load (e.g. ["3 sets of", "10 reps", "50 lb"]
         * If the reps and loads are different, each element is a set in the format: set X: Y x Z (e.g. ["10 x 50 lb", "9 x 55 lb", "8 x 60 lb"]
         */
        var summaryList = [String]()

        if repsAllEqual && loadsAllEqual {
            summaryList.append("\(reps!.count)\u{FEFF} \u{FEFF}sets")
            summaryList.append("\(reps![0])\u{FEFF} \u{FEFF}reps")
            summaryList.append("\(roundDouble(loads![0]))\u{FEFF} \u{FEFF}lb")
            return summaryList
        }
        
        if let reps = reps, let loads = loads {
            for i in 0...(reps.count - 1) {
                summaryList.append("\(reps[i])\u{FEFF} \u{FEFF}reps × \(roundDouble(loads[i]))\u{FEFF} \u{FEFF}lb")
            }
        }
        return summaryList
    }
    
    var shorterSummary: [String] {
        /**
         * Same as above but slightly shorter version.
         * If the reps and loads are all equal, each element is: X, Y reps x Z load (e.g. ["3×", "10 reps × 50 lb"]
         * If the reps and loads are different, each element is a set in the format: ["10 × 50 lb", "9 × 55 lb", "8 × 60 lb"]
         */
        var summaryList = [String]()

        if repsAllEqual && loadsAllEqual {
            summaryList.append("\(reps!.count)×")
            summaryList.append("\(reps![0])\u{FEFF} \u{FEFF}reps × \(roundDouble(loads![0]))\u{FEFF} \u{FEFF}lb")
            return summaryList
        }
        
        if let reps = reps, let loads = loads {
            for i in 0...(reps.count - 1) {
                summaryList.append("\(reps[i])\u{FEFF} \u{FEFF}reps × \(roundDouble(loads[i]))\u{FEFF} \u{FEFF}lb")
            }
        }
        return summaryList
    }

    
    var conciseSummaryString: String {
        if repsAllEqual && loadsAllEqual {
            return "\(reps!.count) × \(reps![0]) × \(roundDouble(loads![0]))\u{FEFF} \u{FEFF}lb"
        }
        
        if let reps = reps, let loads = loads {
            var summaryList = [String]()
            for i in 0...(reps.count - 1) {
                summaryList.append("\(reps[i]) × \(roundDouble(loads[i]))\u{FEFF} \u{FEFF}lb")
            }
            return summaryList.joined(separator: ", ")
        }
        
        return "N/A"
    }
    
    var withJustInputFields: MovementLog {
        /**
         * Returns a MovementLog instance that just pre-populates input fields, except notes.
         */
        return MovementLog(reps: reps, loads: loads, notes: "")
    }



}
