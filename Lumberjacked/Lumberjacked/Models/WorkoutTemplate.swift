//
//  WorkoutTemplate.swift
//  Lumberjacked
//

import Foundation

struct WorkoutTemplateMovement: Codable, Hashable {
    var id: UInt64?
    var movement: UInt64?
    var movement_detail: Movement?
    var movement_log_template: UInt64?
    var movement_log_template_detail: MovementLogTemplate?
    var order: Int?
}

struct WorkoutTemplate: Codable, Hashable {
    var id: UInt64?
    var author: UInt64?
    var name: String
    var movements_details: [WorkoutTemplateMovement]?
    var created_timestamp: Date?
    var updated_timestamp: Date?
}

struct CreateWorkoutTemplateRequest: Codable {
    var name: String
    var movements: [CreateWorkoutTemplateMovementItem]?
    var source_workout: UInt64?
}

struct CreateWorkoutTemplateMovementItem: Codable {
    var movement: UInt64
    var movement_log_template: UInt64?
}
