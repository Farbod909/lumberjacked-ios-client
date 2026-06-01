//
//  WorkoutHistoryViewModelTests.swift
//  LumberjackedTests

import XCTest
@testable import Lumberjacked

final class WorkoutHistoryViewModelTests: XCTestCase {

    func testPastWorkoutsFilterExcludesActiveWorkout() {
        let vm = WorkoutHistoryView.ViewModel()
        let active = Workout(id: 1, start_timestamp: Date(), end_timestamp: nil)
        let finished = Workout(id: 2, start_timestamp: Date(), end_timestamp: Date())
        vm.workouts = [active, finished]

        XCTAssertEqual(vm.pastWorkouts.count, 1)
        XCTAssertEqual(vm.pastWorkouts.first?.id, 2)
    }

    func testPastWorkoutsEmptyWhenNoFinishedWorkouts() {
        let vm = WorkoutHistoryView.ViewModel()
        vm.workouts = [Workout(id: 1, start_timestamp: Date(), end_timestamp: nil)]

        XCTAssertTrue(vm.pastWorkouts.isEmpty)
    }
}
