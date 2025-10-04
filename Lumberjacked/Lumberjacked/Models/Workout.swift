//
//  Workout.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/29/25.
//

import Foundation

struct Workout: Codable, Hashable {
    var id: UInt64?
    var user: UInt64?
    var movements: [UInt64]?
    var start_timestamp: Date?
    var end_timestamp: Date?
    
    var movements_details: [Movement]?
    
    var humanReadableStartTimestamp: String? {
        guard let start_timestamp else {
            return nil
        }

        let now = Date()
        let calendar = Calendar.current

        let dateFormatter = DateFormatter()

        // Handle "Today" and "Yesterday" first
        if calendar.isDateInToday(start_timestamp) {
            return "Today"
        }
        if calendar.isDateInYesterday(start_timestamp) {
            return "Yesterday"
        }

        dateFormatter.dateFormat = "EEEE, MMMM d"
        dateFormatter.timeZone = .current
        return dateFormatter.string(from: start_timestamp)
    }
}

extension Workout {
    var withoutId: Workout {
        var copy = self
        copy.id = nil
        return copy
    }
}

struct CreateOrEditWorkoutRequest: Codable {
    var movements: [UInt64]
}
