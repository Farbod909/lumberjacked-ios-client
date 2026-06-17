//
//  NetworkConfiguration.swift
//  Lumberjacked

import Foundation

enum NetworkConfiguration {
    static let localURL  = "http://192.168.86.30:8000"
    static let remoteURL = "https://lumberjacked-dev-2-1029906100530.us-west2.run.app"

    static var baseURL: String {
        if let envURL = ProcessInfo.processInfo.environment["API_BASE_URL"] {
            return envURL
        }
        if UserDefaults.standard.bool(forKey: "useLocalBackend") {
            return localURL
        }
        return remoteURL
    }
}
