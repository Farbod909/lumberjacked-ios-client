//
//  WorkoutDetailViewModelTests.swift
//  LumberjackedTests

import XCTest
@testable import Lumberjacked

final class WorkoutDetailViewModelTests: XCTestCase {

    private func makeWorkout(withMovements movements: [Movement] = []) -> Workout {
        Workout(id: 42, start_timestamp: Date(), end_timestamp: Date(), movements_details: movements)
    }

    func testInitWithWorkoutStoresWorkout() {
        let vm = WorkoutDetailView.ViewModel(workout: makeWorkout())
        XCTAssertEqual(vm.workout.id, 42)
    }

    func testShowDeleteConfirmationAlertStartsFalse() {
        let vm = WorkoutDetailView.ViewModel(workout: makeWorkout())
        XCTAssertFalse(vm.showDeleteConfirmationAlert)
    }

    func testIsDirtyStartsFalse() {
        let log = MovementLog(id: 1, sets: [LogSet(reps: 10, load: 135, type: "working")], notes: "")
        let movement = Movement(id: 1, name: "Bench Press", notes: "", recorded_log: log)
        let vm = WorkoutDetailView.ViewModel(workout: makeWorkout(withMovements: [movement]))
        XCTAssertFalse(vm.isDirty)
    }

    func testIsDirtyAfterChangingLogNotes() {
        let log = MovementLog(id: 1, sets: [], notes: "original")
        let movement = Movement(id: 1, name: "Bench Press", notes: "", recorded_log: log)
        let vm = WorkoutDetailView.ViewModel(workout: makeWorkout(withMovements: [movement]))
        vm.editableEntries[0].logNotes = "changed"
        XCTAssertTrue(vm.isDirty)
    }

    func testIsDirtyAfterChangingLogSets() {
        let log = MovementLog(id: 1, sets: [LogSet(reps: 10, load: 135, type: "working")], notes: "")
        let movement = Movement(id: 1, name: "Bench Press", notes: "", recorded_log: log)
        let vm = WorkoutDetailView.ViewModel(workout: makeWorkout(withMovements: [movement]))
        vm.editableEntries[0].logSets = [LogSet(reps: 12, load: 135, type: "working")]
        XCTAssertTrue(vm.isDirty)
    }

    func testEditableEntriesInitializedFromRecordedLog() {
        let sets = [LogSet(reps: 8, load: 225, type: "working")]
        let log = MovementLog(id: 5, sets: sets, notes: "felt strong")
        let movement = Movement(id: 1, name: "Deadlift", notes: "", recorded_log: log)
        let vm = WorkoutDetailView.ViewModel(workout: makeWorkout(withMovements: [movement]))

        XCTAssertEqual(vm.editableEntries.count, 1)
        XCTAssertEqual(vm.editableEntries[0].logSets, sets)
        XCTAssertEqual(vm.editableEntries[0].logNotes, "felt strong")
        XCTAssertEqual(vm.editableEntries[0].existingLogId, 5)
    }
}
