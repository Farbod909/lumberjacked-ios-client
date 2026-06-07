//
//  WorkoutDetailViewModelTests.swift
//  LumberjackedTests

import XCTest
@testable import Lumberjacked

final class WorkoutDetailViewModelTests: XCTestCase {

    func testInitWithWorkoutStoresWorkout() {
        let workout = Workout(id: 42, start_timestamp: Date(), end_timestamp: Date())
        let vm = WorkoutDetailView.ViewModel(workout: workout)
        XCTAssertEqual(vm.workout.id, 42)
    }

    func testShowDeleteConfirmationAlertStartsFalse() {
        let workout = Workout(id: 1, start_timestamp: Date())
        let vm = WorkoutDetailView.ViewModel(workout: workout)
        XCTAssertFalse(vm.showDeleteConfirmationAlert)
    }

    func testDestinationStartsNil() {
        let vm = WorkoutDetailView.ViewModel(workout: Workout(id: 1, start_timestamp: Date()))
        XCTAssertNil(vm.destination)
    }

    func testMovementLogTappedSetsDestination() {
        let vm = WorkoutDetailView.ViewModel(workout: Workout(id: 1, start_timestamp: Date()))
        let log = MovementLog(id: 3, movement: 1, reps: [10], loads: [135], notes: "")
        let movement = Movement(id: 1, name: "Bench Press", category: "", notes: "",
                                recommended_warmup_sets: "", recommended_working_sets: "",
                                recommended_rep_range: "", recommended_rpe: "")

        vm.movementLogTapped(log, movement: movement)

        XCTAssertEqual(vm.destination, .movementLogInput(log, movement))
    }
}
