//
//  LoginUITests.swift
//  LumberjackedUITests
//
//  Requires a running server at http://localhost:8000 with a seeded test account.
//  Set TEST_EMAIL / TEST_PASSWORD in the scheme's environment variables, or
//  replace the constants below before running.

import XCTest

final class LoginUITests: XCTestCase {

    private let testEmail    = ProcessInfo.processInfo.environment["TEST_EMAIL"]    ?? "test@example.com"
    private let testPassword = ProcessInfo.processInfo.environment["TEST_PASSWORD"] ?? "password123"

    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchEnvironment["UI_TESTING"] = "1"
        app.launch()
    }

    override func tearDown() {
        app = nil
        super.tearDown()
    }

    // MARK: - Tests

    func testLoginFlow() {
        // Auth sheet should appear automatically — UI_TESTING clears the keychain on launch.
        let emailField = app.textFields["loginEmailField"]
        XCTAssertTrue(emailField.waitForExistence(timeout: 15), "Email field should appear on launch when not authenticated")

        emailField.tap()
        emailField.typeText(testEmail)

        let passwordField = app.secureTextFields["loginPasswordField"]
        passwordField.tap()
        passwordField.typeText(testPassword)

        app.buttons["loginButton"].tap()

        // After successful login the auth sheet dismisses and the main tab bar appears.
        let homeTab = app.tabBars.buttons["Home"]
        XCTAssertTrue(homeTab.waitForExistence(timeout: 15), "Home tab should appear after successful login")
    }

    func testLoginShowsErrorOnBadCredentials() {
        let emailField = app.textFields["loginEmailField"]
        XCTAssertTrue(emailField.waitForExistence(timeout: 15))

        emailField.tap()
        emailField.typeText("wrong@example.com")

        let passwordField = app.secureTextFields["loginPasswordField"]
        passwordField.tap()
        passwordField.typeText("wrongpassword")

        app.buttons["loginButton"].tap()

        // An error alert should appear since credentials are invalid.
        let errorAlert = app.alerts.firstMatch
        XCTAssertTrue(errorAlert.waitForExistence(timeout: 10), "Error alert should appear for invalid credentials")
        errorAlert.buttons.firstMatch.tap()

        // After dismissing the alert the auth sheet should still be visible.
        XCTAssertTrue(emailField.waitForExistence(timeout: 5), "Email field should still be visible after failed login")
    }
}
