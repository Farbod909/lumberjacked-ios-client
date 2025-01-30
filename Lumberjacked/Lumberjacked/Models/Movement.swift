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
    var name: String?
    var category: String?
    var notes: String?
    var created_timestamp: Date?
    var updated_timestamp: Date?
    var recommended_warmup_sets: String?
    var recommended_working_sets: String?
    var recommended_rep_range: String?
    var recommended_rpe: String?
    var recommended_rest_time: UInt16?
    
    var latest_log: MovementLog?
}

//struct CurrentWorkoutMovementDetail: Codable, Hashable, Identifiable {
//    var id: UInt64?
//    var author: UInt64?
//    var name: String?
//    var category: String?
//    var notes: String?
//    var created_timestamp: Date?
//    var updated_timestamp: Date?
//    var recommended_warmup_sets: String?
//    var recommended_working_sets: String?
//    var recommended_rep_range: String?
//    var recommended_rpe: String?
//    var recommended_rest_time: UInt16?
//    
//    var latest_log: CurrentWorkoutMovementLatestLog
//}
