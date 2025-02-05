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
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone.current

        if Calendar.current.isDateInToday(start_timestamp) {
            return "Today"
        }
        if Calendar.current.isDateInYesterday(start_timestamp) {
            return "Yesterday"
        }

        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: start_timestamp)
    }
}

struct CreateWorkoutRequest: Codable {
    var movements: [UInt64]
}
