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
}
