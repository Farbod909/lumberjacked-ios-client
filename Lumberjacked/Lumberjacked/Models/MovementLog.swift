//
//  MovementLog.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/29/25.
//

import Foundation

struct MovementLog: Codable, Hashable {
    var id: UInt64?
    var movement: UInt64?
    var workout: UInt64?
    var reps: [UInt16]?
    var loads: [Double]?
    var notes: String?
    var timestamp: Date?
    
    var for_current_workout: Bool?
}

//struct CurrentWorkoutMovementLatestLog {
//    var id: UInt64?
//    var reps: [UInt16]?
//    var loads: [Double]?
//    var notes: String?
//    var timestamp: Date?
//    
//    var for_current_workout: Bool?
//}
