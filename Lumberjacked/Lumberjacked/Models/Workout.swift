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
        let components = calendar.dateComponents([.day], from: start_timestamp, to: now)

        // Check if the date is within the last 14 days (13 days ago or less)
        if let days = components.day, days < 14 {
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

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
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
