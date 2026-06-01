//
//  LoginView-ViewModel.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/21/25.
//

import SwiftUI

extension LoginView {
    @Observable
    class ViewModel: LoadingTrackable {
        enum LoadingKey { case action }
        var loadingKeys: Set<LoadingKey> = []

        var email = ""
        var password = ""
        var errors = LumberjackedClientErrors()

        private let api: AuthAPIProtocol

        init(api: AuthAPIProtocol = LiveAuthAPI()) {
            self.api = api
        }

        func attemptLogin() async -> Bool {
            loadingKeys.insert(.action)
            defer { loadingKeys.remove(.action) }
            errors.messages = [:]

            do {
                let response = try await api.login(email: email, password: password)
                Keychain.standard.save(
                    response.key, service: "accessToken", account: "lumberjacked")
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

            return false
        }
    }
}
