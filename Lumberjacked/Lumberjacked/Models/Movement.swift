//
//  Movement.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/29/25.
//

import Foundation

struct Movement: Codable, Hashable {
    var id: UInt64?
    var author: UInt64?
    var name: String
    var notes: String
    var resistance_type: String?
    var body_part: String?
    var created_timestamp: Date?
    var updated_timestamp: Date?

    var latest_log: MovementLog?
    var recorded_log: MovementLog?

    // Present when Movement is embedded in a Workout's movements_details.
    var workout_movement_id: UInt64?
    var template: MovementLogTemplate?
}

extension Movement {
    var hasNotes: Bool {
        return notes != ""
    }

    var hasResistanceType: Bool {
        return resistance_type != nil && resistance_type != ""
    }

    var hasBodyPart: Bool {
        return body_part != nil && body_part != ""
    }
}
