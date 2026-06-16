//
//  MovementLog.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/29/25.
//

import Foundation

struct LogSet: Codable, Hashable {
    var reps: Int
    var load: Double?
    var type: String
    var rest_time: Int?
    var isChecked: Bool = false

    enum CodingKeys: String, CodingKey {
        case reps, load, type, rest_time
    }
}

struct MovementLog: Codable, Hashable {
    var id: UInt64?
    var workout_movement: UInt64?
    var sets: [LogSet]?
    var notes: String
    var timestamp: Date?

    var for_current_workout: Bool?
}

extension MovementLog {
    func roundDouble(_ double: Double) -> String {
        let roundedValue = (double * 10).rounded() / 10
        if roundedValue.truncatingRemainder(dividingBy: 1) == 0 {
            return String(Int(roundedValue))
        } else {
            return String(format: "%.1f", roundedValue)
        }
    }

    private var allSameReps: Bool {
        guard let sets = sets, !sets.isEmpty else { return true }
        return sets.allSatisfy { $0.reps == sets[0].reps }
    }

    private var allSameLoad: Bool {
        guard let sets = sets, !sets.isEmpty else { return true }
        return sets.allSatisfy { $0.load == sets[0].load }
    }

    var summary: [String] {
        guard let sets = sets, !sets.isEmpty else { return [] }

        if allSameReps && allSameLoad {
            var result = ["\(sets.count)\u{FEFF} \u{FEFF}sets"]
            result.append("\(sets[0].reps)\u{FEFF} \u{FEFF}reps")
            if let load = sets[0].load {
                result.append("\(roundDouble(load))\u{FEFF} \u{FEFF}lb")
            }
            return result
        }

        return sets.map { set in
            if let load = set.load {
                return "\(set.reps)\u{FEFF} \u{FEFF}reps × \(roundDouble(load))\u{FEFF} \u{FEFF}lb"
            } else {
                return "\(set.reps)\u{FEFF} \u{FEFF}reps"
            }
        }
    }

    var shorterSummary: [String] {
        guard let sets = sets, !sets.isEmpty else { return [] }

        if allSameReps && allSameLoad {
            var result = ["\(sets.count)×"]
            if let load = sets[0].load {
                result.append("\(sets[0].reps)\u{FEFF} \u{FEFF}reps × \(roundDouble(load))\u{FEFF} \u{FEFF}lb")
            } else {
                result.append("\(sets[0].reps)\u{FEFF} \u{FEFF}reps")
            }
            return result
        }

        return sets.map { set in
            if let load = set.load {
                return "\(set.reps)\u{FEFF} \u{FEFF}reps × \(roundDouble(load))\u{FEFF} \u{FEFF}lb"
            } else {
                return "\(set.reps)\u{FEFF} \u{FEFF}reps"
            }
        }
    }

    var conciseSummaryString: String {
        guard let sets = sets, !sets.isEmpty else { return "N/A" }

        if allSameReps && allSameLoad {
            if let load = sets[0].load {
                return "\(sets.count) × \(sets[0].reps) × \(roundDouble(load))\u{FEFF} \u{FEFF}lb"
            } else {
                return "\(sets.count) × \(sets[0].reps)"
            }
        }

        return sets.map { set in
            if let load = set.load {
                return "\(set.reps) × \(roundDouble(load))\u{FEFF} \u{FEFF}lb"
            } else {
                return "\(set.reps)"
            }
        }.joined(separator: ", ")
    }

    var withJustInputFields: MovementLog {
        return MovementLog(sets: sets, notes: "")
    }
}
