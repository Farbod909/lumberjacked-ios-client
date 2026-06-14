//
//  MovementLogTemplate.swift
//  Lumberjacked
//

import Foundation

struct TemplateSet: Codable, Hashable {
    var reps: String
    var type: String
    var rest_time: Int?
}

struct MovementLogTemplate: Codable, Hashable {
    var id: UInt64?
    var author: UInt64?
    var name: String
    var movement: UInt64?
    var sets: [TemplateSet]
}
