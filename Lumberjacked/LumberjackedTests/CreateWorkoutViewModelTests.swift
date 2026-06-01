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

    func testIsLoadingToolbarActionStartsFalse() {
        let vm = CreateWorkoutView.ViewModel()
        XCTAssertFalse(vm.isLoadingToolbarAction)
    }
}
