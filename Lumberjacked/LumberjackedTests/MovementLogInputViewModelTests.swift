//
//  MovementLogInputViewModelTests.swift
//  LumberjackedTests
//

import XCTest
@testable import Lumberjacked

final class MovementLogInputViewModelTests: XCTestCase {

    private func makeMovement(withLog log: MovementLog? = nil) -> Movement {
        Movement(id: 1, name: "Bench Press", notes: "", latest_log: log)
    }

    private func makeLog(sets: [LogSet] = []) -> MovementLog {
        MovementLog(id: 1, sets: sets, notes: "")
    }

    // MARK: - canSave

    func testCanSaveReturnsFalseWhenNoSets() {
        let vm = MovementLogInputView.ViewModel(
            movementLog: MovementLog(notes: ""),
            movement: makeMovement(),
            workout: nil)
        XCTAssertFalse(vm.canSave())
    }

    func testCanSaveReturnsTrueWithValidSets() {
        let vm = MovementLogInputView.ViewModel(
            movementLog: MovementLog(notes: ""),
            movement: makeMovement(),
            workout: nil)
        vm.sets = [LogSet(reps: 10, load: 135, type: "working", rest_time: nil)]
        XCTAssertTrue(vm.canSave())
    }

    func testCanSaveReturnsFalseWhenAnySetHasZeroReps() {
        let vm = MovementLogInputView.ViewModel(
            movementLog: MovementLog(notes: ""),
            movement: makeMovement(),
            workout: nil)
        vm.sets = [
            LogSet(reps: 10, load: 135, type: "working", rest_time: nil),
            LogSet(reps: 0,  load: 135, type: "working", rest_time: nil),
        ]
        XCTAssertFalse(vm.canSave())
    }

    func testCanSaveReturnsTrueWithMultipleValidSets() {
        let vm = MovementLogInputView.ViewModel(
            movementLog: MovementLog(notes: ""),
            movement: makeMovement(),
            workout: nil)
        vm.sets = [
            LogSet(reps: 8,  load: 135, type: "warmup",  rest_time: 60),
            LogSet(reps: 10, load: 155, type: "working", rest_time: 120),
            LogSet(reps: 10, load: 155, type: "working", rest_time: 120),
        ]
        XCTAssertTrue(vm.canSave())
    }

    func testCanSaveReturnsTrueForSetWithNilLoad() {
        let vm = MovementLogInputView.ViewModel(
            movementLog: MovementLog(notes: ""),
            movement: makeMovement(),
            workout: nil)
        vm.sets = [LogSet(reps: 5, load: nil, type: "working", rest_time: nil)]
        XCTAssertTrue(vm.canSave())
    }

    // MARK: - inputMode

    func testInputModeIsActiveWorkoutWhenWorkoutPresent() {
        let workout = Workout(id: 1, start_timestamp: Date())
        let vm = MovementLogInputView.ViewModel(
            movementLog: MovementLog(notes: ""),
            movement: makeMovement(),
            workout: workout)
        if case .activeWorkout = vm.inputMode {
            // pass
        } else {
            XCTFail("Expected .activeWorkout mode")
        }
    }

    func testInputModeIsEditLogWhenNoWorkout() {
        let vm = MovementLogInputView.ViewModel(
            movementLog: MovementLog(notes: ""),
            movement: makeMovement(),
            workout: nil)
        if case .editLog = vm.inputMode {
            // pass
        } else {
            XCTFail("Expected .editLog mode")
        }
    }

    func testActiveWorkoutModePreviousSetsFromLatestLog() {
        let previousSets = [LogSet(reps: 10, load: 135, type: "working", rest_time: nil)]
        let log = MovementLog(id: 1, sets: previousSets, notes: "")
        let movement = makeMovement(withLog: log)
        let workout = Workout(id: 1, start_timestamp: Date())

        let vm = MovementLogInputView.ViewModel(
            movementLog: MovementLog(notes: ""),
            movement: movement,
            workout: workout)

        if case .activeWorkout(let prev) = vm.inputMode {
            XCTAssertEqual(prev?.count, 1)
            XCTAssertEqual(prev?.first?.reps, 10)
        } else {
            XCTFail("Expected .activeWorkout mode")
        }
    }

    func testActiveWorkoutModeWithNoLatestLogHasNilPreviousSets() {
        let workout = Workout(id: 1, start_timestamp: Date())
        let vm = MovementLogInputView.ViewModel(
            movementLog: MovementLog(notes: ""),
            movement: makeMovement(withLog: nil),
            workout: workout)

        if case .activeWorkout(let prev) = vm.inputMode {
            XCTAssertNil(prev)
        } else {
            XCTFail("Expected .activeWorkout mode")
        }
    }

    // MARK: - Sets initialized from movementLog

    func testSetsInitializedFromMovementLog() {
        let sets = [
            LogSet(reps: 10, load: 135, type: "working", rest_time: 120),
            LogSet(reps: 10, load: 135, type: "working", rest_time: 120),
        ]
        let log = MovementLog(id: 1, sets: sets, notes: "")
        let vm = MovementLogInputView.ViewModel(
            movementLog: log,
            movement: makeMovement(),
            workout: nil)

        XCTAssertEqual(vm.sets.count, 2)
        XCTAssertEqual(vm.sets[0].reps, 10)
    }

    func testSetsInitializedEmptyForNewLog() {
        let vm = MovementLogInputView.ViewModel(
            movementLog: MovementLog(notes: ""),
            movement: makeMovement(),
            workout: nil)
        XCTAssertEqual(vm.sets.count, 0)
    }

    // MARK: - Save (async, using mock)

    @MainActor
    func testFormSubmitCallsCreateForNewLog() async {
        let mockAPI = MockMovementLogAPI()
        let vm = MovementLogInputView.ViewModel(
            movementLog: MovementLog(notes: ""),
            movement: makeMovement(),
            workout: Workout(id: 1, start_timestamp: Date()),
            api: mockAPI)
        vm.sets = [LogSet(reps: 10, load: 135, type: "working", rest_time: nil)]

        var dismissed = false
        await vm.formSubmit(dismissAction: { dismissed = true })

        XCTAssertTrue(dismissed)
        XCTAssertFalse(vm.toolbarActionLoading)
    }

    @MainActor
    func testFormSubmitDoesNotDismissWhenAPIFails() async {
        let mockAPI = MockMovementLogAPI()
        mockAPI.errorToThrow = RemoteNetworkingError(statusCode: 500, messages: nil)

        let vm = MovementLogInputView.ViewModel(
            movementLog: MovementLog(notes: ""),
            movement: makeMovement(),
            workout: nil,
            api: mockAPI)
        vm.sets = [LogSet(reps: 10, load: 135, type: "working", rest_time: nil)]

        var dismissed = false
        await vm.formSubmit(dismissAction: { dismissed = true })

        XCTAssertFalse(dismissed)
        XCTAssertFalse(vm.toolbarActionLoading)
    }

    @MainActor
    func testDeleteLogCallsDismissOnSuccess() async {
        let mockAPI = MockMovementLogAPI()
        let log = makeLog(sets: [LogSet(reps: 5, load: 100, type: "working", rest_time: nil)])

        let vm = MovementLogInputView.ViewModel(
            movementLog: log,
            movement: makeMovement(),
            workout: nil,
            api: mockAPI)

        var dismissed = false
        await vm.attemptDeleteLog(dismissAction: { dismissed = true })

        XCTAssertTrue(dismissed)
    }
}
