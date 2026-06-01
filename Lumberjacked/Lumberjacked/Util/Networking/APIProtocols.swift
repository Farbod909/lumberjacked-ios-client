//
//  APIProtocols.swift
//  Lumberjacked
//

import Foundation

// MARK: - Workout

protocol WorkoutAPIProtocol {
    func getCurrentWorkout() async throws -> Workout
    func getWorkouts() async throws -> APIResponseList<Workout>
    func getWorkout(workoutId: UInt64) async throws -> Workout
    func endWorkout(id: UInt64) async throws
    func deleteWorkout(id: UInt64) async throws
    func createWorkout(movements: [UInt64]) async throws -> Workout
    func updateWorkout(workoutId: UInt64, movements: [UInt64]) async throws -> Workout
}

// MARK: - Movement

protocol MovementAPIProtocol {
    func getMovements() async throws -> APIResponseList<Movement>
    func getMovement(movementId: UInt64) async throws -> Movement
    func createMovement(movement: Movement) async throws -> Movement
    func updateMovement(movementId: UInt64, movement: Movement) async throws -> Movement
    func deleteMovement(movementId: UInt64) async throws
}

// MARK: - MovementLog

protocol MovementLogAPIProtocol {
    func getMovementLogs(movementId: UInt64) async throws -> APIResponseList<MovementLog>
    func createLog(movementLog: MovementLog) async throws -> MovementLog
    func updateLog(movementLogId: UInt64, movementLog: MovementLog) async throws -> MovementLog
    func deleteLog(movementLogId: UInt64) async throws
}

// MARK: - Auth

protocol AuthAPIProtocol {
    func login(email: String, password: String) async throws -> LoginResponse
    func signup(email: String, password1: String, password2: String) async throws -> SignupResponse
    func logout() async throws
}

// MARK: - Live Implementations

struct LiveWorkoutAPI: WorkoutAPIProtocol {
    func getCurrentWorkout() async throws -> Workout {
        let options = Networking.RequestOptions(url: "/api/workouts/current/", method: .GET)
        guard let result: Workout = try await Networking.shared.request(options: options) else {
            throw RemoteNetworkingError(statusCode: 0, messages: nil)
        }
        return result
    }

    func getWorkouts() async throws -> APIResponseList<Workout> {
        let options = Networking.RequestOptions(url: "/api/workouts/", method: .GET)
        guard let result: APIResponseList<Workout> = try await Networking.shared.request(options: options) else {
            throw RemoteNetworkingError(statusCode: 0, messages: nil)
        }
        return result
    }

    func getWorkout(workoutId: UInt64) async throws -> Workout {
        let options = Networking.RequestOptions(url: "/api/workouts/\(workoutId)/", method: .GET)
        guard let result: Workout = try await Networking.shared.request(options: options) else {
            throw RemoteNetworkingError(statusCode: 0, messages: nil)
        }
        return result
    }

    func endWorkout(id: UInt64) async throws {
        let options = Networking.RequestOptions(url: "/api/workouts/\(id)/end/", method: .GET)
        try await Networking.shared.request(options: options)
    }

    func deleteWorkout(id: UInt64) async throws {
        let options = Networking.RequestOptions(url: "/api/workouts/\(id)/", method: .DELETE)
        try await Networking.shared.request(options: options)
    }

    func createWorkout(movements: [UInt64]) async throws -> Workout {
        let body = CreateOrEditWorkoutRequest(movements: movements)
        let options = Networking.RequestOptions(
            url: "/api/workouts/",
            body: body,
            method: .POST,
            headers: [("application/json", "Content-Type")])
        guard let result: Workout = try await Networking.shared.request(options: options) else {
            throw RemoteNetworkingError(statusCode: 0, messages: nil)
        }
        return result
    }

    func updateWorkout(workoutId: UInt64, movements: [UInt64]) async throws -> Workout {
        let body = CreateOrEditWorkoutRequest(movements: movements)
        let options = Networking.RequestOptions(
            url: "/api/workouts/\(workoutId)/",
            body: body,
            method: .PATCH,
            headers: [("application/json", "Content-Type")])
        guard let result: Workout = try await Networking.shared.request(options: options) else {
            throw RemoteNetworkingError(statusCode: 0, messages: nil)
        }
        return result
    }
}

struct LiveMovementAPI: MovementAPIProtocol {
    func getMovements() async throws -> APIResponseList<Movement> {
        let options = Networking.RequestOptions(url: "/api/movements/", method: .GET)
        guard let result: APIResponseList<Movement> = try await Networking.shared.request(options: options) else {
            throw RemoteNetworkingError(statusCode: 0, messages: nil)
        }
        return result
    }

    func getMovement(movementId: UInt64) async throws -> Movement {
        let options = Networking.RequestOptions(url: "/api/movements/\(movementId)/", method: .GET)
        guard let result: Movement = try await Networking.shared.request(options: options) else {
            throw RemoteNetworkingError(statusCode: 0, messages: nil)
        }
        return result
    }

    func createMovement(movement: Movement) async throws -> Movement {
        let options = Networking.RequestOptions(
            url: "/api/movements/",
            body: movement,
            method: .POST,
            headers: [("application/json", "Content-Type")])
        guard let result: Movement = try await Networking.shared.request(options: options) else {
            throw RemoteNetworkingError(statusCode: 0, messages: nil)
        }
        return result
    }

    func updateMovement(movementId: UInt64, movement: Movement) async throws -> Movement {
        let options = Networking.RequestOptions(
            url: "/api/movements/\(movementId)/",
            body: movement,
            method: .PATCH,
            headers: [("application/json", "Content-Type")])
        guard let result: Movement = try await Networking.shared.request(options: options) else {
            throw RemoteNetworkingError(statusCode: 0, messages: nil)
        }
        return result
    }

    func deleteMovement(movementId: UInt64) async throws {
        let options = Networking.RequestOptions(url: "/api/movements/\(movementId)/", method: .DELETE)
        try await Networking.shared.request(options: options)
    }
}

struct LiveMovementLogAPI: MovementLogAPIProtocol {
    func getMovementLogs(movementId: UInt64) async throws -> APIResponseList<MovementLog> {
        let options = Networking.RequestOptions(url: "/api/movement-logs/?movement=\(movementId)", method: .GET)
        guard let result: APIResponseList<MovementLog> = try await Networking.shared.request(options: options) else {
            throw RemoteNetworkingError(statusCode: 0, messages: nil)
        }
        return result
    }

    func createLog(movementLog: MovementLog) async throws -> MovementLog {
        let options = Networking.RequestOptions(
            url: "/api/movement-logs/",
            body: movementLog,
            method: .POST,
            headers: [("application/json", "Content-Type")])
        guard let result: MovementLog = try await Networking.shared.request(options: options) else {
            throw RemoteNetworkingError(statusCode: 0, messages: nil)
        }
        return result
    }

    func updateLog(movementLogId: UInt64, movementLog: MovementLog) async throws -> MovementLog {
        let options = Networking.RequestOptions(
            url: "/api/movement-logs/\(movementLogId)/",
            body: movementLog,
            method: .PATCH,
            headers: [("application/json", "Content-Type")])
        guard let result: MovementLog = try await Networking.shared.request(options: options) else {
            throw RemoteNetworkingError(statusCode: 0, messages: nil)
        }
        return result
    }

    func deleteLog(movementLogId: UInt64) async throws {
        let options = Networking.RequestOptions(url: "/api/movement-logs/\(movementLogId)/", method: .DELETE)
        try await Networking.shared.request(options: options)
    }
}

struct LiveAuthAPI: AuthAPIProtocol {
    func login(email: String, password: String) async throws -> LoginResponse {
        let body = LoginRequest(email: email, password: password)
        let options = Networking.RequestOptions(
            url: "/auth/login/",
            body: body,
            method: .POST,
            headers: [("application/json", "Content-Type")])
        guard let result: LoginResponse = try await Networking.shared.request(options: options) else {
            throw RemoteNetworkingError(statusCode: 0, messages: nil)
        }
        return result
    }

    func signup(email: String, password1: String, password2: String) async throws -> SignupResponse {
        let body = SignupRequest(email: email, password1: password1, password2: password2)
        let options = Networking.RequestOptions(
            url: "/auth/registration/",
            body: body,
            method: .POST,
            headers: [("application/json", "Content-Type")])
        guard let result: SignupResponse = try await Networking.shared.request(options: options) else {
            throw RemoteNetworkingError(statusCode: 0, messages: nil)
        }
        return result
    }

    func logout() async throws {
        let options = Networking.RequestOptions(url: "/auth/logout/", method: .POST)
        try await Networking.shared.request(options: options)
    }
}
