//
//  NetworkConfiguration.swift
//  Lumberjacked

enum NetworkConfiguration {
    #if DEBUG
    static let baseURL = "http://localhost:8000"
    #else
    static let baseURL = "https://lumberjacked-dev-2-1029906100530.us-west2.run.app"
    #endif
}
