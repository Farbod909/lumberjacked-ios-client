//
//  SettingsViewModelTests.swift
//  LumberjackedTests

import XCTest
@testable import Lumberjacked

final class SettingsViewModelTests: XCTestCase {

    func testViewModelCanBeInstantiated() {
        let vm = SettingsView.ViewModel()
        XCTAssertNotNil(vm)
    }
}
