//
//  MovementInputViewModelTests.swift
//  LumberjackedTests

import XCTest
@testable import Lumberjacked

final class MovementInputViewModelTests: XCTestCase {

    private func makeMovement(id: UInt64? = nil, name: String = "Bench Press") -> Movement {
        Movement(id: id, name: name, notes: "")
    }

    func testInitStoresMovement() {
        let movement = makeMovement(id: 5, name: "Deadlift")
        let vm = MovementInputView.ViewModel(movement: movement)
        XCTAssertEqual(vm.movement.id, 5)
        XCTAssertEqual(vm.movement.name, "Deadlift")
    }

    func testSaveActionLoadingStartsFalse() {
        let vm = MovementInputView.ViewModel(movement: makeMovement())
        XCTAssertFalse(vm.saveActionLoading)
    }
}
