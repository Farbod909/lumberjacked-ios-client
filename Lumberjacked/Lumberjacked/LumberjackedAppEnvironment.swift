//
//  LumberjackedApp-ViewModel.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/22/25.
//

import SwiftUI


class LumberjackedAppEnvironment: ObservableObject {
    @Published var isNotAuthenticated: Bool

    @Published var showAlert = false
    @Published var alertMessage = ""

    init() {
        if ProcessInfo.processInfo.environment["UI_TESTING"] == "1" {
            Keychain.standard.delete(service: "accessToken", account: "lumberjacked")
        }
        isNotAuthenticated = Keychain.standard.read(
            service: "accessToken", account: "lumberjacked") == nil

        NotificationCenter.default.addObserver(
            forName: .appUnauthorized,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.isNotAuthenticated = true
        }
    }

    func evaluateAuthenticationStatus() {
        isNotAuthenticated = Keychain.standard.read(
            service: "accessToken", account: "lumberjacked") == nil
    }
}
