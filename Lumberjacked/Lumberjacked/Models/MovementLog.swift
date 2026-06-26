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
    private func formatLoad(_ lbValue: Double, unit: WeightUnit) -> String {
        let displayValue = unit.fromLb(lbValue)
        let rounded = (displayValue * 10).rounded() / 10
        if rounded.truncatingRemainder(dividingBy: 1) == 0 {
            return String(Int(rounded))
        } else {
            return String(format: "%.1f", rounded)
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

    func summary(unit: WeightUnit) -> [String] {
        guard let sets = sets, !sets.isEmpty else { return [] }

        if allSameReps && allSameLoad {
            var result = ["\(sets.count)\u{FEFF} \u{FEFF}sets"]
            result.append("\(sets[0].reps)\u{FEFF} \u{FEFF}reps")
            if let load = sets[0].load {
                result.append("\(formatLoad(load, unit: unit))\u{FEFF} \u{FEFF}\(unit.unitLabel)")
            }
            return result
        }

        return sets.map { set in
            if let load = set.load {
                return "\(set.reps)\u{FEFF} \u{FEFF}reps × \(formatLoad(load, unit: unit))\u{FEFF} \u{FEFF}\(unit.unitLabel)"
            } else {
                return "\(set.reps)\u{FEFF} \u{FEFF}reps"
            }
        }
    }

    func shorterSummary(unit: WeightUnit) -> [String] {
        guard let sets = sets, !sets.isEmpty else { return [] }

        if allSameReps && allSameLoad {
            var result = ["\(sets.count)×"]
            if let load = sets[0].load {
                result.append("\(sets[0].reps)\u{FEFF} \u{FEFF}reps × \(formatLoad(load, unit: unit))\u{FEFF} \u{FEFF}\(unit.unitLabel)")
            } else {
                result.append("\(sets[0].reps)\u{FEFF} \u{FEFF}reps")
            }
            return result
        }

        return sets.map { set in
            if let load = set.load {
                return "\(set.reps)\u{FEFF} \u{FEFF}reps × \(formatLoad(load, unit: unit))\u{FEFF} \u{FEFF}\(unit.unitLabel)"
            } else {
                return "\(set.reps)\u{FEFF} \u{FEFF}reps"
            }
        }
    }

    func conciseSummaryString(unit: WeightUnit) -> String {
        guard let sets = sets, !sets.isEmpty else { return "N/A" }

        if allSameReps && allSameLoad {
            if let load = sets[0].load {
                return "\(sets.count) × \(sets[0].reps) × \(formatLoad(load, unit: unit))\u{FEFF} \u{FEFF}\(unit.unitLabel)"
            } else {
                return "\(sets.count) × \(sets[0].reps)"
            }
        }

        return sets.map { set in
            if let load = set.load {
                return "\(set.reps) × \(formatLoad(load, unit: unit))\u{FEFF} \u{FEFF}\(unit.unitLabel)"
            } else {
                return "\(set.reps)"
            }
        }.joined(separator: ", ")
    }

    var withJustInputFields: MovementLog {
        return MovementLog(sets: sets, notes: "")
    }
}
