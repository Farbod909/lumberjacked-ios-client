//
//  MovementLogInputViewModelTests.swift
//  LumberjackedTests

import XCTest
@testable import Lumberjacked

final class MovementLogInputViewModelTests: XCTestCase {

    private func makeMovement() -> Movement {
        Movement(id: 1, name: "Bench Press", category: "", notes: "",
                 recommended_warmup_sets: "", recommended_working_sets: "",
                 recommended_rep_range: "", recommended_rpe: "")
    }

    func testCanSaveReturnsFalseWhenFieldsNil() {
        let vm = MovementLogInputView.ViewModel(
            movementLog: MovementLog(notes: ""),
            movement: makeMovement(),
            workout: nil)
        XCTAssertFalse(vm.canSave())
    }

    func testCanSaveReturnsTrueWithValidEqualSetsInput() {
        let vm = MovementLogInputView.ViewModel(
            movementLog: MovementLog(notes: ""),
            movement: makeMovement(),
            workout: nil)
        vm.selectedInputStyle = "Equal Sets"
        vm.equalSetsMovementLogInput.sets = 3
        vm.equalSetsMovementLogInput.reps = 10
        vm.equalSetsMovementLogInput.load = 135.0
        XCTAssertTrue(vm.canSave())
    }

    func testCanSaveReturnsFalseForCustomSets() {
        let vm = MovementLogInputView.ViewModel(
            movementLog: MovementLog(notes: ""),
            movement: makeMovement(),
            workout: nil)
        vm.selectedInputStyle = "Custom Sets"
        XCTAssertFalse(vm.canSave())
    }

    func testDefaultInputStyleIsEqualSets() {
        let vm = MovementLogInputView.ViewModel(
            movementLog: MovementLog(notes: ""),
            movement: makeMovement(),
            workout: nil)
        XCTAssertEqual(vm.selectedInputStyle, "Equal Sets")
    }
}
