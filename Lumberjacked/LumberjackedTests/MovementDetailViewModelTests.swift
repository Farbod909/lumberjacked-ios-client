//
//  MovementDetailViewModelTests.swift
//  LumberjackedTests

import XCTest
@testable import Lumberjacked

final class MovementDetailViewModelTests: XCTestCase {

    private func makeMovement() -> Movement {
        Movement(id: 1, name: "Bench Press", notes: "")
    }

    func testInitStoresMovement() {
        let movement = makeMovement()
        let vm = MovementDetailView.ViewModel(movement: movement)
        XCTAssertEqual(vm.movement.id, 1)
        XCTAssertEqual(vm.movement.name, "Bench Press")
    }

    func testInitWithLogsStoresLogs() {
        let log = MovementLog(id: 1, workout_movement: 1, sets: [LogSet(reps: 10, load: 135, type: "working"), LogSet(reps: 10, load: 135, type: "working")], notes: "")
        let vm = MovementDetailView.ViewModel(movement: makeMovement(), movementLogs: [log])
        XCTAssertEqual(vm.movementLogs.count, 1)
    }

    func testShowDeleteAlertStartsFalse() {
        let vm = MovementDetailView.ViewModel(movement: makeMovement())
        XCTAssertFalse(vm.showDeleteConfirmationAlert)
    }

    func testDestinationStartsNil() {
        let vm = MovementDetailView.ViewModel(movement: makeMovement())
        XCTAssertNil(vm.destination)
    }

    func testLogTappedSetsEditLogDestination() {
        let vm = MovementDetailView.ViewModel(movement: makeMovement())
        let log = MovementLog(id: 7, workout_movement: 1, sets: [LogSet(reps: 8, load: 100, type: "working")], notes: "")

        vm.logTapped(log)

        XCTAssertEqual(vm.destination, .editLog(log))
    }

    func testNewLogTappedSetsNewLogDestination() {
        let vm = MovementDetailView.ViewModel(movement: makeMovement())

        vm.newLogTapped()

        XCTAssertEqual(vm.destination, .newLog)
    }
}
