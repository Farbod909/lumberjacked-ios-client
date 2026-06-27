//
//  MovementDetailViewModelTests.swift
//  LumberjackedTests

import XCTest
@testable import Lumberjacked

final class MovementDetailViewModelTests: XCTestCase {

    private func makeMovement() -> Movement {
        Movement(id: 1, name: "Bench Press", notes: "")
    }

    private func makeLog(id: UInt64) -> MovementLog {
        MovementLog(id: id, workout_movement: 1, sets: [LogSet(reps: 10, load: 135, type: "working")], notes: "")
    }

    func testInitStoresMovement() {
        let movement = makeMovement()
        let vm = MovementDetailView.ViewModel(movement: movement)
        XCTAssertEqual(vm.movement.id, 1)
        XCTAssertEqual(vm.movement.name, "Bench Press")
    }

    func testInitWithLogsStoresLogs() {
        let log = makeLog(id: 1)
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
        let log = makeLog(id: 7)

        vm.logTapped(log)

        XCTAssertEqual(vm.destination, .editLog(log))
    }

    func testLogSavedUpdatesExistingLog() {
        let original = makeLog(id: 5)
        let vm = MovementDetailView.ViewModel(movement: makeMovement(), movementLogs: [original])

        var updated = original
        updated.notes = "heavier next time"
        vm.logSaved(updated)

        XCTAssertEqual(vm.movementLogs.count, 1)
        XCTAssertEqual(vm.movementLogs[0].notes, "heavier next time")
    }

    func testLogSavedIgnoresUnknownLog() {
        let existing = makeLog(id: 5)
        let vm = MovementDetailView.ViewModel(movement: makeMovement(), movementLogs: [existing])

        let unrelated = makeLog(id: 99)
        vm.logSaved(unrelated)

        XCTAssertEqual(vm.movementLogs.count, 1)
        XCTAssertEqual(vm.movementLogs[0].id, 5)
    }

    func testLogDeletedRemovesLog() {
        let log1 = makeLog(id: 1)
        let log2 = makeLog(id: 2)
        let vm = MovementDetailView.ViewModel(movement: makeMovement(), movementLogs: [log1, log2])

        vm.logDeleted(log1)

        XCTAssertEqual(vm.movementLogs.count, 1)
        XCTAssertEqual(vm.movementLogs[0].id, 2)
    }

    func testLogDeletedIgnoresUnknownLog() {
        let existing = makeLog(id: 5)
        let vm = MovementDetailView.ViewModel(movement: makeMovement(), movementLogs: [existing])

        let unrelated = makeLog(id: 99)
        vm.logDeleted(unrelated)

        XCTAssertEqual(vm.movementLogs.count, 1)
    }
}
