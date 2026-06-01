//
//  MovementDetailViewModelTests.swift
//  LumberjackedTests

import XCTest
@testable import Lumberjacked

final class MovementDetailViewModelTests: XCTestCase {

    private func makeMovement() -> Movement {
        Movement(id: 1, name: "Bench Press", category: "Chest", notes: "",
                 recommended_warmup_sets: "", recommended_working_sets: "",
                 recommended_rep_range: "", recommended_rpe: "")
    }

    func testInitStoresMovement() {
        let movement = makeMovement()
        let vm = MovementDetailView.ViewModel(movement: movement)
        XCTAssertEqual(vm.movement.id, 1)
        XCTAssertEqual(vm.movement.name, "Bench Press")
    }

    func testInitWithLogsStoresLogs() {
        let log = MovementLog(id: 1, movement: 1, reps: [10, 10], loads: [135, 135], notes: "")
        let vm = MovementDetailView.ViewModel(movement: makeMovement(), movementLogs: [log])
        XCTAssertEqual(vm.movementLogs.count, 1)
    }

    func testShowDeleteAlertStartsFalse() {
        let vm = MovementDetailView.ViewModel(movement: makeMovement())
        XCTAssertFalse(vm.showDeleteConfirmationAlert)
    }
}
