//
//  MovementCatalogViewModelTests.swift
//  LumberjackedTests

import XCTest
@testable import Lumberjacked

final class MovementCatalogViewModelTests: XCTestCase {

    private func makeMovement(id: UInt64, name: String) -> Movement {
        Movement(id: id, name: name, category: "", notes: "",
                 recommended_warmup_sets: "", recommended_working_sets: "",
                 recommended_rep_range: "", recommended_rpe: "")
    }

    func testFilteredMovementsReturnsAllWhenSearchEmpty() {
        let vm = MovementCatalogView.ViewModel()
        vm.movements = [makeMovement(id: 1, name: "Bench Press"), makeMovement(id: 2, name: "Squat")]

        XCTAssertEqual(vm.filteredMovements.count, 2)
    }

    func testFilteredMovementsMatchesPartialName() {
        let vm = MovementCatalogView.ViewModel()
        vm.movements = [makeMovement(id: 1, name: "Bench Press"), makeMovement(id: 2, name: "Squat")]
        vm.searchText = "bench"

        XCTAssertEqual(vm.filteredMovements.count, 1)
        XCTAssertEqual(vm.filteredMovements.first?.name, "Bench Press")
    }

    func testFilteredMovementsReturnsEmptyWhenNoMatch() {
        let vm = MovementCatalogView.ViewModel()
        vm.movements = [makeMovement(id: 1, name: "Bench Press")]
        vm.searchText = "deadlift"

        XCTAssertTrue(vm.filteredMovements.isEmpty)
    }

    func testMovementTappedSetsDestination() {
        let vm = MovementCatalogView.ViewModel()
        let movement = makeMovement(id: 3, name: "Deadlift")

        vm.movementTapped(movement)

        XCTAssertEqual(vm.destination, .movementDetail(movement))
    }

    func testDestinationStartsNil() {
        let vm = MovementCatalogView.ViewModel()
        XCTAssertNil(vm.destination)
    }
}
