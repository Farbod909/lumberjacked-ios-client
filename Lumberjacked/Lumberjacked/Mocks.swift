//
//  Mocks.swift
//  Lumberjacked
//

#if DEBUG
import Foundation

// MARK: - MockWorkoutAPI

final class MockWorkoutAPI: WorkoutAPIProtocol {
    private let currentWorkout: Workout?

    init(currentWorkout: Workout? = PreviewData.activeWorkout) {
        self.currentWorkout = currentWorkout
    }

    func getCurrentWorkout() async throws -> Workout {
        guard let workout = currentWorkout else {
            throw RemoteNetworkingError(statusCode: 404, messages: nil)
        }
        return workout
    }

    func getWorkouts() async throws -> APIResponseList<Workout> {
        return APIResponseList(count: PreviewData.pastWorkouts.count, results: PreviewData.pastWorkouts)
    }

    func getWorkout(workoutId: UInt64) async throws -> Workout {
        return PreviewData.pastWorkouts.first(where: { $0.id == workoutId })
            ?? PreviewData.pastWorkout_today
    }

    func endWorkout(id: UInt64) async throws { }

    func deleteWorkout(id: UInt64) async throws { }

    func createWorkout(movements: [UInt64]) async throws -> Workout {
        return PreviewData.activeWorkout
    }

    func updateWorkout(workoutId: UInt64, movements: [UInt64]) async throws -> Workout {
        return PreviewData.activeWorkout
    }
}

// MARK: - MockMovementAPI

final class MockMovementAPI: MovementAPIProtocol {
    func getMovements() async throws -> APIResponseList<Movement> {
        return APIResponseList(count: PreviewData.movements.count, results: PreviewData.movements)
    }

    func getMovement(movementId: UInt64) async throws -> Movement {
        return PreviewData.movements.first(where: { $0.id == movementId })
            ?? PreviewData.benchPress
    }

    func createMovement(movement: Movement) async throws -> Movement {
        var created = movement
        created.id = 99
        return created
    }

    func updateMovement(movementId: UInt64, movement: Movement) async throws -> Movement {
        var updated = movement
        updated.id = movementId
        return updated
    }

    func deleteMovement(movementId: UInt64) async throws { }
}

// MARK: - MockMovementLogAPI

final class MockMovementLogAPI: MovementLogAPIProtocol {
    func getMovementLogs(movementId: UInt64) async throws -> APIResponseList<MovementLog> {
        let logs = PreviewData.benchPressLogs.filter { $0.movement == movementId }
        return APIResponseList(count: logs.count, results: logs)
    }

    func createLog(movementLog: MovementLog) async throws -> MovementLog {
        var created = movementLog
        created.id = 99
        return created
    }

    func updateLog(movementLogId: UInt64, movementLog: MovementLog) async throws -> MovementLog {
        var updated = movementLog
        updated.id = movementLogId
        return updated
    }

    func deleteLog(movementLogId: UInt64) async throws { }
}

// MARK: - MockAuthAPI

final class MockAuthAPI: AuthAPIProtocol {
    func login(email: String, password: String) async throws -> LoginResponse {
        return LoginResponse(key: "mock-token")
    }

    func signup(email: String, password1: String, password2: String) async throws -> SignupResponse {
        return SignupResponse(key: "mock-token")
    }

    func logout() async throws { }
}
#endif
