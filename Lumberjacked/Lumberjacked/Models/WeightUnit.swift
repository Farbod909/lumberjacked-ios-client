//
//  WeightUnit.swift
//  Lumberjacked
//

enum WeightUnit: String {
    case lb = "lb"
    case kg = "kg"

    private static let kgPerLb: Double = 0.453592

    var columnLabel: String {
        switch self {
        case .lb: return "lbs"
        case .kg: return "kg"
        }
    }

    var unitLabel: String { rawValue }

    func fromLb(_ lbValue: Double) -> Double {
        self == .kg ? lbValue * Self.kgPerLb : lbValue
    }

    func toLb(_ displayValue: Double) -> Double {
        self == .kg ? displayValue / Self.kgPerLb : displayValue
    }
}
