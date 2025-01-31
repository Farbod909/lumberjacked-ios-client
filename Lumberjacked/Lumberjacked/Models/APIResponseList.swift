//
//  APIResponseList.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/30/25.
//

import Foundation

struct APIResponseList<T: Codable>: Codable {
    var count: Int
    var next: String?
    var previous: String?
    var results: [T]
}
