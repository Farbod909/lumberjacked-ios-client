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

    var nextPageRelativeURL: String? {
        guard let next, let url = URL(string: next) else { return nil }
        var relative = url.path
        if let query = url.query { relative += "?\(query)" }
        return relative
    }
}
