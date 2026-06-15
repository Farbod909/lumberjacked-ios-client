//
//  EditableSet.swift
//  Lumberjacked
//

import Foundation

struct EditableSet: Identifiable {
    var id = UUID()
    var type: String       // "warmup" | "working" | "failure" | "myoreps"
    var reps: String       // always String internally; Int for log sets, free text for templates
    var load: Double?
    var rest_time: Int?
    var isChecked: Bool = false
}

// MARK: - Set type display

extension EditableSet {
    enum SetType: String, CaseIterable {
        case warmup  = "warmup"
        case working = "working"
        case failure = "failure"
        case myoreps = "myoreps"

        var displayLabel: String {
            switch self {
            case .warmup:  return "W"
            case .working: return "#"  // replaced by number at render time
            case .failure: return "F"
            case .myoreps: return "M"
            }
        }

        var fullName: String {
            switch self {
            case .warmup:  return "Warmup"
            case .working: return "Working"
            case .failure: return "Failure"
            case .myoreps: return "Myorep"
            }
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
    }

    var asLogSet: LogSet {
        LogSet(reps: Int(reps) ?? 0, load: load, type: type, rest_time: rest_time)
    }
}

// MARK: - Conversion from/to TemplateSet

extension EditableSet {
    init(from templateSet: TemplateSet) {
        type     = templateSet.type
        reps     = templateSet.reps
        rest_time = templateSet.rest_time
    }

    var asTemplateSet: TemplateSet {
        TemplateSet(reps: reps, type: type, rest_time: rest_time)
    }
}

// MARK: - Defaults

extension EditableSet {
    static func defaultWorkingSet(copyingRestFrom prior: EditableSet? = nil) -> EditableSet {
        EditableSet(type: "working", reps: "", load: nil, rest_time: prior?.rest_time)
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
