//
//  AuthViewModelTests.swift
//  LumberjackedTests

import XCTest
@testable import Lumberjacked

final class AuthViewModelTests: XCTestCase {

    func testShowSignupStartsFalse() {
        let vm = AuthView.ViewModel()
        XCTAssertFalse(vm.showSignup)
    }

    func testToggleShowSignup() {
        let vm = AuthView.ViewModel()
        vm.showSignup = true
        XCTAssertTrue(vm.showSignup)
        vm.showSignup = false
        XCTAssertFalse(vm.showSignup)
    }
}
