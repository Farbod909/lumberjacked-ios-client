//
//  Auth.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/22/25.
//

struct LoginRequest: Codable {
    var email: String
    var password: String
}

struct LoginResponse: Codable {
    var key: String
}

struct SignupRequest: Codable {
    var email: String
    var password1: String
    var password2: String
}
