//
//  LoginView-ViewModel.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/21/25.
//

import SwiftUI

extension LoginView {
    @Observable
    class ViewModel {
        var email = ""
        var password = ""

        var isLoadingToolbarAction = false
        var errors = LumberjackedClientErrors()

        private let api: AuthAPIProtocol

        init(api: AuthAPIProtocol = LiveAuthAPI()) {
            self.api = api
        }

        func attemptLogin() async -> Bool {
            isLoadingToolbarAction = true
            errors.messages = [:]

            do {
                let response = try await api.login(email: email, password: password)
                Keychain.standard.save(
                    response.key, service: "accessToken", account: "lumberjacked")
                isLoadingToolbarAction = false
                return true
            } catch let error as RemoteNetworkingError {
                if let messages = error.messages {
                    errors.messages = messages
                } else {
                    errors.messages["detail"] = "Unknown error"
                }
            } catch {
                errors.messages["detail"] = "Unknown error"
            }

            isLoadingToolbarAction = false
            return false
        }
    }
}
