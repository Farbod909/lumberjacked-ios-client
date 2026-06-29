//
//  MovementEnums.swift
//  Lumberjacked
//

import Foundation

enum ResistanceType: String, CaseIterable, Codable {
    case bodyweight      = "bodyweight"
    case dumbbell        = "dumbbell"
    case barbell         = "barbell"
    case machine         = "machine"
    case cable           = "cable"
    case kettlebell      = "kettlebell"
    case resistanceBand  = "resistance_band"
    case medicineBall    = "medicine_ball"
    case smithMachine    = "smith_machine"
    case suspensionTRX   = "suspension_trx"
    case fixedBarbell    = "fixed_barbell"
    case weightedVest    = "weighted_vest"
    case sandbag         = "sandbag"
    case beltAttached    = "belt_attached"
    case digital         = "digital"
    case other           = "other"

    var displayName: String {
        switch self {
        case .bodyweight:     return "Bodyweight"
        case .dumbbell:       return "Dumbbell"
        case .barbell:        return "Barbell"
        case .machine:        return "Machine"
        case .cable:          return "Cable"
        case .kettlebell:     return "Kettlebell"
        case .resistanceBand: return "Resistance Band"
        case .medicineBall:   return "Medicine Ball"
        case .smithMachine:   return "Smith Machine"
        case .suspensionTRX:  return "Suspension (TRX)"
        case .fixedBarbell:   return "Fixed Barbell"
        case .weightedVest:   return "Weighted Vest"
        case .sandbag:        return "Sandbag"
        case .beltAttached:   return "Belt-attached"
        case .digital:        return "Digital"
        case .other:          return "Other"
        }
    }
}

enum BodyPart: String, CaseIterable, Codable {
    // Broad
    case fullBody           = "full_body"
    case upperBody          = "upper_body"
    case lowerBody          = "lower_body"
    case core               = "core"
    // Groups
    case chest              = "chest"
    case back               = "back"
    case shoulders          = "shoulders"
    case arms               = "arms"
    case glutes             = "glutes"
    case quads              = "quads"
    case hamstrings         = "hamstrings"
    case calves             = "calves"
    case hipFlexors         = "hip_flexors"
    case adductors          = "adductors"
    case abductors          = "abductors"
    // Specific
    case upperChest         = "upper_chest"
    case lowerChest         = "lower_chest"
    case lats               = "lats"
    case traps              = "traps"
    case rhomboids          = "rhomboids"
    case lowerBack          = "lower_back"
    case frontDelts         = "front_delts"
    case sideDelts          = "side_delts"
    case rearDelts          = "rear_delts"
    case biceps             = "biceps"
    case triceps            = "triceps"
    case forearms           = "forearms"
    case gluteMax           = "glute_max"
    case gluteMed           = "glute_med"
    case gastrocnemius      = "gastrocnemius"
    case soleus             = "soleus"
    case rectusAbdominis    = "rectus_abdominis"
    case obliques           = "obliques"
    case transverseAbdominis = "transverse_abdominis"

    var displayName: String {
        switch self {
        case .fullBody:            return "Full Body"
        case .upperBody:           return "Upper Body"
        case .lowerBody:           return "Lower Body"
        case .core:                return "Core"
        case .chest:               return "Chest"
        case .back:                return "Back"
        case .shoulders:           return "Shoulders"
        case .arms:                return "Arms"
        case .glutes:              return "Glutes"
        case .quads:               return "Quads"
        case .hamstrings:          return "Hamstrings"
        case .calves:              return "Calves"
        case .hipFlexors:          return "Hip Flexors"
        case .adductors:           return "Adductors"
        case .abductors:           return "Abductors"
        case .upperChest:          return "Upper Chest"
        case .lowerChest:          return "Lower Chest"
        case .lats:                return "Lats"
        case .traps:               return "Traps"
        case .rhomboids:           return "Rhomboids"
        case .lowerBack:           return "Lower Back"
        case .frontDelts:          return "Front Delts"
        case .sideDelts:           return "Side Delts"
        case .rearDelts:           return "Rear Delts"
        case .biceps:              return "Biceps"
        case .triceps:             return "Triceps"
        case .forearms:            return "Forearms"
        case .gluteMax:            return "Glute Max"
        case .gluteMed:            return "Glute Med"
        case .gastrocnemius:       return "Gastrocnemius"
        case .soleus:              return "Soleus"
        case .rectusAbdominis:     return "Rectus Abdominis"
        case .obliques:            return "Obliques"
        case .transverseAbdominis: return "Transverse Abdominis"
        }
    }

    enum Category: String, CaseIterable {
        case broad    = "Broad"
        case groups   = "Groups"
        case specific = "Specific"
    }

    var category: Category {
        switch self {
        case .fullBody, .upperBody, .lowerBody, .core:
            return .broad
        case .chest, .back, .shoulders, .arms, .glutes, .quads,
             .hamstrings, .calves, .hipFlexors, .adductors, .abductors:
            return .groups
        case .upperChest, .lowerChest, .lats, .traps, .rhomboids, .lowerBack,
             .frontDelts, .sideDelts, .rearDelts, .biceps, .triceps, .forearms,
             .gluteMax, .gluteMed, .gastrocnemius, .soleus, .rectusAbdominis,
             .obliques, .transverseAbdominis:
            return .specific
        }
    }

    static func cases(in category: Category) -> [BodyPart] {
        allCases.filter { $0.category == category }
    }
}
