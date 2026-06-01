//
//  SignupView-ViewModel.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/21/25.
//

import SwiftUI

extension SignupView {
    @Observable
    class ViewModel: LoadingTrackable {
        enum LoadingKey { case action }
        var loadingKeys: Set<LoadingKey> = []

        var email = ""
        var password1 = ""
        var password2 = ""
        var errors = LumberjackedClientErrors()

        private let api: AuthAPIProtocol

        init(api: AuthAPIProtocol = LiveAuthAPI()) {
            self.api = api
        }

        func attemptSignup() async -> Bool {
            loadingKeys.insert(.action)
            defer { loadingKeys.remove(.action) }
            errors.messages = [:]

            do {
                let response = try await api.signup(
                    email: email, password1: password1, password2: password2)
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
