//
//  Mocks.swift
//  Lumberjacked
//

#if DEBUG
import Foundation

// MARK: - MockWorkoutAPI

final class MockWorkoutAPI: WorkoutAPIProtocol {
    private let currentWorkout: Workout?
    var errorToThrow: Error?

    init(currentWorkout: Workout? = PreviewData.activeWorkout) {
        self.currentWorkout = currentWorkout
    }

    func getCurrentWorkout() async throws -> Workout {
        if let error = errorToThrow { throw error }
        guard let workout = currentWorkout else {
            throw RemoteNetworkingError(statusCode: 404, messages: nil)
        }
        return workout
    }

    func getWorkouts() async throws -> APIResponseList<Workout> {
        if let error = errorToThrow { throw error }
        return APIResponseList(count: PreviewData.pastWorkouts.count, results: PreviewData.pastWorkouts)
    }

    func getWorkout(workoutId: UInt64) async throws -> Workout {
        if let error = errorToThrow { throw error }
        return PreviewData.pastWorkouts.first(where: { $0.id == workoutId })
            ?? PreviewData.pastWorkout_today
    }

    func endWorkout(id: UInt64) async throws {
        if let error = errorToThrow { throw error }
    }

    func deleteWorkout(id: UInt64) async throws {
        if let error = errorToThrow { throw error }
    }

    func createWorkout(movements: [UInt64]) async throws -> Workout {
        if let error = errorToThrow { throw error }
        return PreviewData.activeWorkout
    }

    func updateWorkout(workoutId: UInt64, movements: [UInt64]) async throws -> Workout {
        if let error = errorToThrow { throw error }
        return PreviewData.activeWorkout
    }
}

// MARK: - MockMovementAPI

final class MockMovementAPI: MovementAPIProtocol {
    var errorToThrow: Error?

    func getMovements() async throws -> APIResponseList<Movement> {
        if let error = errorToThrow { throw error }
        return APIResponseList(count: PreviewData.movements.count, results: PreviewData.movements)
    }

    func getMovement(movementId: UInt64) async throws -> Movement {
        if let error = errorToThrow { throw error }
        return PreviewData.movements.first(where: { $0.id == movementId })
            ?? PreviewData.benchPress
    }

    func createMovement(movement: Movement) async throws -> Movement {
        if let error = errorToThrow { throw error }
        var created = movement
        created.id = 99
        return created
    }

    func updateMovement(movementId: UInt64, movement: Movement) async throws -> Movement {
        if let error = errorToThrow { throw error }
        var updated = movement
        updated.id = movementId
        return updated
    }

    func deleteMovement(movementId: UInt64) async throws {
        if let error = errorToThrow { throw error }
    }
}

// MARK: - MockMovementLogAPI

final class MockMovementLogAPI: MovementLogAPIProtocol {
    var errorToThrow: Error?

    func getMovementLogs(movementId: UInt64) async throws -> APIResponseList<MovementLog> {
        if let error = errorToThrow { throw error }
        let logs = PreviewData.benchPressLogs.filter { $0.movement == movementId }
        return APIResponseList(count: logs.count, results: logs)
    }

    func createLog(movementLog: MovementLog) async throws -> MovementLog {
        if let error = errorToThrow { throw error }
        var created = movementLog
        created.id = 99
        return created
    }

    func updateLog(movementLogId: UInt64, movementLog: MovementLog) async throws -> MovementLog {
        if let error = errorToThrow { throw error }
        var updated = movementLog
        updated.id = movementLogId
        return updated
    }

    func deleteLog(movementLogId: UInt64) async throws {
        if let error = errorToThrow { throw error }
    }
}

// MARK: - MockAuthAPI

final class MockAuthAPI: AuthAPIProtocol {
    var errorToThrow: Error?

    func login(email: String, password: String) async throws -> LoginResponse {
        if let error = errorToThrow { throw error }
        return LoginResponse(key: "mock-token")
    }

    func signup(email: String, password1: String, password2: String) async throws -> SignupResponse {
        if let error = errorToThrow { throw error }
        return SignupResponse(key: "mock-token")
    }

    func logout() async throws {
        if let error = errorToThrow { throw error }
    }
}
#endif
