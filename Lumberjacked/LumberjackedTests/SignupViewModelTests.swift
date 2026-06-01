//
//  SignupViewModelTests.swift
//  LumberjackedTests

import XCTest
@testable import Lumberjacked

final class SignupViewModelTests: XCTestCase {

    func testInitialState() {
        let vm = SignupView.ViewModel()
        XCTAssertEqual(vm.email, "")
        XCTAssertEqual(vm.password1, "")
        XCTAssertEqual(vm.password2, "")
        XCTAssertFalse(vm.isLoadingToolbarAction)
    }
}
