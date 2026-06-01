//
//  LumberjackedClientErrorsTests.swift
//  LumberjackedTests

import XCTest
@testable import Lumberjacked

final class LumberjackedClientErrorsTests: XCTestCase {

    // MARK: - hasError

    func testHasError_missingKey_returnsFalse() {
        let errors = LumberjackedClientErrors()
        XCTAssertFalse(errors.hasError(key: "non_field_errors"))
    }

    func testHasError_emptyArray_returnsFalse() {
        var errors = LumberjackedClientErrors()
        errors.messages["non_field_errors"] = NSArray()
        XCTAssertFalse(errors.hasError(key: "non_field_errors"))
    }

    func testHasError_nsArrayWithStrings_returnsTrue() {
        var errors = LumberjackedClientErrors()
        errors.messages["non_field_errors"] = NSArray(array: ["Unable to log in with provided credentials."])
        XCTAssertTrue(errors.hasError(key: "non_field_errors"))
    }

    func testHasError_swiftStringArray_returnsTrue() {
        var errors = LumberjackedClientErrors()
        errors.messages["detail"] = ["Not found."]
        XCTAssertTrue(errors.hasError(key: "detail"))
    }

    func testHasError_emptyDict_returnsFalse() {
        var errors = LumberjackedClientErrors()
        errors.messages["field"] = [String: Any]()
        XCTAssertFalse(errors.hasError(key: "field"))
    }

    func testHasError_nonEmptyDict_returnsTrue() {
        var errors = LumberjackedClientErrors()
        errors.messages["email"] = ["email": ["Enter a valid email address."]]
        XCTAssertTrue(errors.hasError(key: "email"))
    }

    // MARK: - errorMessage

    func testErrorMessage_missingKey_returnsEmpty() {
        let errors = LumberjackedClientErrors()
        XCTAssertEqual(errors.errorMessage(key: "non_field_errors"), "")
    }

    func testErrorMessage_nsArrayFromJSONSerialization_returnsJoinedString() throws {
        // Simulates exactly what JSONSerialization produces from a DRF 400 response body.
        let json = #"{"non_field_errors": ["Unable to log in with provided credentials."]}"#.data(using: .utf8)!
        let parsed = try JSONSerialization.jsonObject(with: json) as! [String: Any]

        var errors = LumberjackedClientErrors()
        errors.messages = parsed

        XCTAssertEqual(
            errors.errorMessage(key: "non_field_errors"),
            "Unable to log in with provided credentials."
        )
    }

    func testErrorMessage_nsArrayMultipleMessages_returnsNewlineSeparated() throws {
        let json = #"{"non_field_errors": ["Error one.", "Error two."]}"#.data(using: .utf8)!
        let parsed = try JSONSerialization.jsonObject(with: json) as! [String: Any]

        var errors = LumberjackedClientErrors()
        errors.messages = parsed

        XCTAssertEqual(errors.errorMessage(key: "non_field_errors"), "Error one.\nError two.")
    }

    func testErrorMessage_detailString_returnsString() throws {
        let json = #"{"detail": "Authentication credentials were not provided."}"#.data(using: .utf8)!
        let parsed = try JSONSerialization.jsonObject(with: json) as! [String: Any]

        var errors = LumberjackedClientErrors()
        errors.messages = parsed

        XCTAssertEqual(
            errors.errorMessage(key: "detail"),
            "Authentication credentials were not provided."
        )
    }

    func testErrorMessage_detailPlainString_returnsString() throws {
        // Some dj-rest-auth versions return {"detail": "..."} as a plain string, not an array
        let json = #"{"detail": "Unable to log in with provided credentials."}"#.data(using: .utf8)!
        let parsed = try JSONSerialization.jsonObject(with: json) as! [String: Any]

        var errors = LumberjackedClientErrors()
        errors.messages = parsed

        XCTAssertTrue(errors.hasError(key: "detail"))
        XCTAssertEqual(errors.errorMessage(key: "detail"), "Unable to log in with provided credentials.")
    }

    func testErrorMessage_nestedFieldErrors_returnsMessages() throws {
        let json = #"{"email": ["Enter a valid email address."]}"#.data(using: .utf8)!
        let parsed = try JSONSerialization.jsonObject(with: json) as! [String: Any]

        var errors = LumberjackedClientErrors()
        errors.messages = parsed

        XCTAssertTrue(errors.hasError(key: "email"))
        XCTAssertEqual(errors.errorMessage(key: "email"), "Enter a valid email address.")
    }
}
