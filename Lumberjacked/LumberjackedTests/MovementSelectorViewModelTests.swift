//
//  MovementSelectorViewModelTests.swift
//  LumberjackedTests

import XCTest
@testable import Lumberjacked

final class MovementSelectorViewModelTests: XCTestCase {

    private func makeMovement(id: UInt64, name: String) -> Movement {
        Movement(id: id, name: name, notes: "")
    }

    func testInitWithoutWorkoutHasEmptySelection() {
        let vm = MovementSelectorView.ViewModel()
        XCTAssertTrue(vm.selectedMovements.isEmpty)
        XCTAssertNil(vm.workout)
    }

    func testInitWithWorkoutPopulatesSelectedMovements() {
        let m1 = makeMovement(id: 1, name: "Bench Press")
        let m2 = makeMovement(id: 2, name: "Squat")
        let workout = Workout(id: 1, movements_details: [m1, m2])
        let vm = MovementSelectorView.ViewModel(workout: workout)

        XCTAssertEqual(vm.selectedMovements.count, 2)
        XCTAssertEqual(vm.selectedMovements.first?.id, 1)
    }
}
