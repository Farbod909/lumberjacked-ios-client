//
//  NetworkConfiguration.swift
//  Lumberjacked

import Foundation

enum NetworkConfiguration {
    static let baseURL: String = {
        if let envURL = ProcessInfo.processInfo.environment["API_BASE_URL"] {
            return envURL
        }
        #if DEBUG
        return "http://localhost:8000"
        #else
        return "https://lumberjacked-dev-2-1029906100530.us-west2.run.app"
        #endif
    }()
}
