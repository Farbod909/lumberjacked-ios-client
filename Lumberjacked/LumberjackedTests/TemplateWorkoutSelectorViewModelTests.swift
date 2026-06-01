//
//  TemplateWorkoutSelectorViewModelTests.swift
//  LumberjackedTests

import XCTest
@testable import Lumberjacked

final class TemplateWorkoutSelectorViewModelTests: XCTestCase {

    func testInitialStateIsLoading() {
        let vm = TemplateWorkoutSelectorView.ViewModel()
        XCTAssertTrue(vm.isLoading(.load))
    }

    func testInitialWorkoutsEmpty() {
        let vm = TemplateWorkoutSelectorView.ViewModel()
        XCTAssertTrue(vm.workouts.isEmpty)
    }
}
