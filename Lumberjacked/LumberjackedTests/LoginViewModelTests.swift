//
//  LoginViewModelTests.swift
//  LumberjackedTests

import XCTest
@testable import Lumberjacked

final class LoginViewModelTests: XCTestCase {

    func testInitialState() {
        let vm = LoginView.ViewModel()
        XCTAssertEqual(vm.email, "")
        XCTAssertEqual(vm.password, "")
        XCTAssertFalse(vm.isLoading(.action))
    }
}
