//
//  RestTimerEnvironmentTests.swift
//  LumberjackedTests
//

import XCTest
@testable import Lumberjacked

final class RestTimerEnvironmentTests: XCTestCase {

    // MARK: - Initial state

    func testInitialStateIsNotRunning() {
        let timer = RestTimerEnvironment()
        XCTAssertFalse(timer.isRunning)
        XCTAssertEqual(timer.timeRemaining, 0)
        XCTAssertEqual(timer.totalTime, 0)
        XCTAssertNil(timer.activeSetId)
        XCTAssertFalse(timer.showTimerAlert)
    }

    // MARK: - start()

    func testStartSetsRunningState() {
        let timer = RestTimerEnvironment()
        let id = UUID()
        timer.start(seconds: 90, setId: id)

        XCTAssertTrue(timer.isRunning)
        XCTAssertEqual(timer.timeRemaining, 90)
        XCTAssertEqual(timer.totalTime, 90)
        XCTAssertEqual(timer.activeSetId, id)
        XCTAssertFalse(timer.showTimerAlert)
    }

    func testStartReplacesExistingTimer() {
        let timer = RestTimerEnvironment()
        let id1 = UUID()
        let id2 = UUID()

        timer.start(seconds: 120, setId: id1)
        timer.start(seconds: 60, setId: id2)

        XCTAssertEqual(timer.activeSetId, id2)
        XCTAssertEqual(timer.timeRemaining, 60)
        XCTAssertEqual(timer.totalTime, 60)
    }

    func testStartClearsShowTimerAlert() {
        let timer = RestTimerEnvironment()
        timer.showTimerAlert = true

        timer.start(seconds: 30, setId: UUID())

        XCTAssertFalse(timer.showTimerAlert)
    }

    // MARK: - cancel()

    func testCancelStopsTimer() {
        let timer = RestTimerEnvironment()
        timer.start(seconds: 60, setId: UUID())
        timer.cancel()

        XCTAssertFalse(timer.isRunning)
        XCTAssertNil(timer.activeSetId)
        XCTAssertEqual(timer.timeRemaining, 0)
        XCTAssertEqual(timer.totalTime, 0)
    }

    // MARK: - formattedTime

    func testFormattedTimeUnderOneMinute() {
        let timer = RestTimerEnvironment()
        XCTAssertEqual(timer.formattedTime(45), "0:45")
    }

    func testFormattedTimeExactlyOneMinute() {
        let timer = RestTimerEnvironment()
        XCTAssertEqual(timer.formattedTime(60), "1:00")
    }

    func testFormattedTimeMinutesAndSeconds() {
        let timer = RestTimerEnvironment()
        XCTAssertEqual(timer.formattedTime(90), "1:30")
        XCTAssertEqual(timer.formattedTime(125), "2:05")
    }

    func testFormattedTimeZero() {
        let timer = RestTimerEnvironment()
        XCTAssertEqual(timer.formattedTime(0), "0:00")
    }

    func testFormattedTimeRemainingMatchesTimeRemaining() {
        let timer = RestTimerEnvironment()
        timer.start(seconds: 75, setId: UUID())
        XCTAssertEqual(timer.formattedTimeRemaining, timer.formattedTime(75))
    }

    // MARK: - Countdown (async)

    @MainActor
    func testTimerCountsDown() async throws {
        let timer = RestTimerEnvironment()
        timer.start(seconds: 2, setId: UUID())

        try await Task.sleep(for: .seconds(1.5))

        XCTAssertTrue(timer.timeRemaining < 2)
        XCTAssertTrue(timer.isRunning)
        timer.cancel()
    }

    @MainActor
    func testTimerFiresAlertAtZero() async throws {
        let timer = RestTimerEnvironment()
        timer.start(seconds: 1, setId: UUID())

        try await Task.sleep(for: .seconds(2.5))

        XCTAssertFalse(timer.isRunning)
        XCTAssertTrue(timer.showTimerAlert)
        XCTAssertNil(timer.activeSetId)
    }
}
