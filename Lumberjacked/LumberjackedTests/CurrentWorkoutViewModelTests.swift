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

    func testAlertStartsNil() {
        let vm = CurrentWorkoutView.ViewModel()
        XCTAssertNil(vm.alert)
    }

    func testSettingAlertMakesItNonNil() {
        let vm = CurrentWorkoutView.ViewModel()
        vm.alert = AppAlert(title: "Test")
        XCTAssertNotNil(vm.alert)
    }

    func testClearingAlertMakesItNil() {
        let vm = CurrentWorkoutView.ViewModel()
        vm.alert = AppAlert(title: "Test")
        vm.alert = nil
        XCTAssertNil(vm.alert)
    }
}
