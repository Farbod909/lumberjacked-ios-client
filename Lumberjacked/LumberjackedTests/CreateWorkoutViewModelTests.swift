//
//  CreateWorkoutViewModelTests.swift
//  LumberjackedTests

import XCTest
@testable import Lumberjacked

final class CreateWorkoutViewModelTests: XCTestCase {

    func testTemplateWorkoutStartsNil() {
        let vm = CreateWorkoutView.ViewModel()
        XCTAssertNil(vm.templateWorkout)
    }

    func testIsLoadingActionStartsFalse() {
        let vm = CreateWorkoutView.ViewModel()
        XCTAssertFalse(vm.isLoading(.action))
    }
}
