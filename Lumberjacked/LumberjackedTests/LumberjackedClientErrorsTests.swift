//
//  FieldErrorsTests.swift
//  LumberjackedTests
//
//  Tests for the fieldErrors + AppAlert error extraction logic in form ViewModels.
//

import XCTest
@testable import Lumberjacked

// MARK: - Test helpers

private final class ThrowingAuthAPI: AuthAPIProtocol {
    let error: Error

    init(error: Error) {
        self.error = error
    }

    func login(email: String, password: String) async throws -> LoginResponse {
        throw error
    }

    func signup(email: String, password1: String, password2: String) async throws -> SignupResponse {
        throw error
    }

    func logout() async throws {
        throw error
    }
}

// MARK: - FieldErrorsTests

final class FieldErrorsTests: XCTestCase {

    func testFieldError_nsArrayValue_populatesFieldErrors() async {
        let json = #"{"email": ["Enter a valid email address."]}"#.data(using: .utf8)!
        let parsed = try! JSONSerialization.jsonObject(with: json) as! [String: Any]
        let api = ThrowingAuthAPI(error: RemoteNetworkingError(statusCode: 400, messages: parsed))
        let vm = LoginView.ViewModel(api: api)

        _ = await vm.attemptLogin()

        XCTAssertEqual(vm.fieldErrors["email"], "Enter a valid email address.")
        XCTAssertNil(vm.alert)
    }

    func testFieldError_multipleMessages_joinedByNewline() async {
        let json = #"{"email": ["Error one.", "Error two."]}"#.data(using: .utf8)!
        let parsed = try! JSONSerialization.jsonObject(with: json) as! [String: Any]
        let api = ThrowingAuthAPI(error: RemoteNetworkingError(statusCode: 400, messages: parsed))
        let vm = LoginView.ViewModel(api: api)

        _ = await vm.attemptLogin()

        XCTAssertEqual(vm.fieldErrors["email"], "Error one.\nError two.")
    }

    func testDetailError_routesToAlert() async {
        let json = #"{"detail": "Unable to log in with provided credentials."}"#.data(using: .utf8)!
        let parsed = try! JSONSerialization.jsonObject(with: json) as! [String: Any]
        let api = ThrowingAuthAPI(error: RemoteNetworkingError(statusCode: 400, messages: parsed))
        let vm = LoginView.ViewModel(api: api)

        _ = await vm.attemptLogin()

        XCTAssertNotNil(vm.alert)
        XCTAssertEqual(vm.alert?.message, "Unable to log in with provided credentials.")
        XCTAssertTrue(vm.fieldErrors.isEmpty)
    }

    func testNonFieldErrors_routesToAlert() async {
        let json = #"{"non_field_errors": ["Unable to log in with provided credentials."]}"#.data(using: .utf8)!
        let parsed = try! JSONSerialization.jsonObject(with: json) as! [String: Any]
        let api = ThrowingAuthAPI(error: RemoteNetworkingError(statusCode: 400, messages: parsed))
        let vm = LoginView.ViewModel(api: api)

        _ = await vm.attemptLogin()

        XCTAssertNotNil(vm.alert)
        XCTAssertEqual(vm.alert?.message, "Unable to log in with provided credentials.")
        XCTAssertTrue(vm.fieldErrors.isEmpty)
    }

    func testNilMessages_setsGenericAlert() async {
        let api = ThrowingAuthAPI(error: RemoteNetworkingError(statusCode: 500, messages: nil))
        let vm = LoginView.ViewModel(api: api)

        _ = await vm.attemptLogin()

        XCTAssertNotNil(vm.alert)
        XCTAssertEqual(vm.alert?.message, "Unknown error")
        XCTAssertTrue(vm.fieldErrors.isEmpty)
    }

    func testFieldErrorsClearedOnResubmit() async {
        let json = #"{"email": ["Enter a valid email address."]}"#.data(using: .utf8)!
        let parsed = try! JSONSerialization.jsonObject(with: json) as! [String: Any]
        let api = ThrowingAuthAPI(error: RemoteNetworkingError(statusCode: 400, messages: parsed))
        let vm = LoginView.ViewModel(api: api)

        _ = await vm.attemptLogin()
        XCTAssertFalse(vm.fieldErrors.isEmpty)

        _ = await vm.attemptLogin()
        // fieldErrors is cleared at start of submit, then repopulated from the same error
        XCTAssertEqual(vm.fieldErrors["email"], "Enter a valid email address.")
    }
}
