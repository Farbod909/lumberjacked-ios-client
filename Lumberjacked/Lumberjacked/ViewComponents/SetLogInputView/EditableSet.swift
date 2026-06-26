//
//  EditableSet.swift
//  Lumberjacked
//

import Foundation

struct EditableSet: Identifiable {
    var id = UUID()
    var type: String       // "warmup" | "working" | "failure" | "dropset" | "myoreps"
    var reps: String       // always String internally; Int for log sets, free text for templates
    var load: Double?
    var rest_time: Int?
    var isChecked: Bool = false
}

// MARK: - Set type display

extension EditableSet {
    enum SetType: String, CaseIterable {
        case warmup   = "warmup"
        case working  = "working"
        case dropset  = "dropset"
        case failure  = "failure"
        case myoreps  = "myoreps"

        var displayLabel: String {
            switch self {
            case .warmup:   return "W"
            case .working:  return "#"  // replaced by number at render time
            case .dropset:  return "D"
            case .failure:  return "F"
            case .myoreps:  return "M"
            }
        }

        var fullName: String {
            switch self {
            case .warmup:   return "Warmup"
            case .working:  return "Working"
            case .dropset:  return "Dropset"
            case .failure:  return "Failure"
            case .myoreps:  return "Myorep"
            }
        }

        // Dropset and myoreps rest_time is the rest BEFORE the set (pre-rest),
        // not after it. This flips which pill the value drives in the UI.
        var isPreRest: Bool {
            switch self {
            case .dropset, .myoreps: return true
            default: return false
            }
        }
    }

    // Returns the user's configured default rest time (in seconds) for the given type.
    // Pre-rest types (dropset, myoreps) default to 0 and 20 respectively; post-rest
    // types (warmup, working, failure) default to 0 and 120.
    static func defaultRestTime(for type: SetType) -> Int {
        let ud = UserDefaults.standard
        switch type {
        case .warmup:
            // 0 is both valid and the default; integer(forKey:) returns 0 when unset, which is correct.
            return ud.integer(forKey: "defaultWarmupRestTime")
        case .working, .failure:
            // Use object check so an explicitly saved 0 is honoured vs. "never written" → 120.
            return ud.object(forKey: "defaultRestTime") != nil ? ud.integer(forKey: "defaultRestTime") : 120
        case .dropset:
            return ud.integer(forKey: "defaultDropsetRestTime")
        case .myoreps:
            return ud.object(forKey: "defaultMyorepsRestTime") != nil ? ud.integer(forKey: "defaultMyorepsRestTime") : 20
        }
    }

    var setType: SetType {
        get { SetType(rawValue: type) ?? .working }
        set { type = newValue.rawValue }
    }

    func displayLabel(workingSetIndex: Int) -> String {
        switch setType {
        case .working: return "\(workingSetIndex)"
        default:       return setType.displayLabel
        }
    }
}

// MARK: - Conversion from/to LogSet

extension EditableSet {
    init(from logSet: LogSet) {
        type      = logSet.type
        reps      = logSet.reps > 0 ? String(logSet.reps) : ""
        load      = logSet.load
        rest_time = logSet.rest_time
        isChecked = logSet.isChecked
    }

    var asLogSet: LogSet {
        LogSet(reps: Int(reps) ?? 0, load: load, type: type, rest_time: rest_time, isChecked: isChecked)
    }
}

// MARK: - Conversion from/to TemplateSet

extension EditableSet {
    init(from templateSet: TemplateSet) {
        type      = templateSet.type
        reps      = templateSet.reps ?? ""
        rest_time = templateSet.rest_time
    }

    var asTemplateSet: TemplateSet {
        TemplateSet(reps: reps.isEmpty ? nil : reps, type: type, rest_time: rest_time)
    }
}

// MARK: - Defaults

extension EditableSet {
    static func defaultSet(copyingFrom prior: EditableSet? = nil) -> EditableSet {
        let newType = prior?.setType ?? .working
        return EditableSet(
            type: newType.rawValue,
            reps: prior?.reps ?? "",
            load: prior?.load,
            rest_time: prior?.rest_time ?? defaultRestTime(for: newType)
        )
    }
}

// MARK: - Working set numbering

extension Array where Element == EditableSet {
    func workingSetIndex(for id: UUID) -> Int {
        var counter = 1
        for set in self {
            if set.id == id { return counter }
            if set.setType == .working { counter += 1 }
        }
        return counter
    }
}
