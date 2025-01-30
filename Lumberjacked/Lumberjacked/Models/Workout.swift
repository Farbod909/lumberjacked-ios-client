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
}

//struct CurrentWorkout: Codable, Hashable, Identifiable {
//    var id: Int64?
//    var user: Int64?
//    var start_timestamp: Date?
//    var end_timestamp: Date?
//    
//    var movements_details: [CurrentWorkoutMovementDetail]?
//}

