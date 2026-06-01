//
//  CurrentWorkoutViewModelTests.swift
//  LumberjackedTests

import XCTest
@testable import Lumberjacked

final class CurrentWorkoutViewModelTests: XCTestCase {

    func testInitialStateHasNoCurrentWorkout() {
        let vm = CurrentWorkoutView.ViewModel()
        XCTAssertNil(vm.currentWorkout)
    }

    func testInitialStateShowsLoading() {
        let vm = CurrentWorkoutView.ViewModel()
        XCTAssertTrue(vm.isLoading(.currentWorkout))
        XCTAssertTrue(vm.isLoading(.movements))
    }

    func testShowFinishWorkoutAlertStartsFalse() {
        let vm = CurrentWorkoutView.ViewModel()
        XCTAssertFalse(vm.showFinishWorkoutConfirmationAlert)
    }
}
