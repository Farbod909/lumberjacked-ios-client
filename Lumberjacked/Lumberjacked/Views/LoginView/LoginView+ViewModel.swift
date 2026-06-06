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
        var fieldErrors: [String: String] = [:]
        var alert: AppAlert?

        private let api: AuthAPIProtocol

        init(api: AuthAPIProtocol = LiveAuthAPI()) {
            self.api = api
        }

        func attemptLogin() async -> Bool {
            loadingKeys.insert(.action)
            defer { loadingKeys.remove(.action) }
            fieldErrors = [:]

            do {
                let response = try await api.login(email: email, password: password)
                Keychain.standard.save(
                    response.key, service: "accessToken", account: "lumberjacked")
                return true
            } catch let error as RemoteNetworkingError {
                handleNetworkError(error)
            } catch {
                alert = AppAlert(title: "Error", message: error.localizedDescription)
            }

            return false
        }

        private func handleNetworkError(_ error: RemoteNetworkingError) {
            guard let messages = error.messages else {
                alert = AppAlert(title: "Error", message: "Unknown error")
                return
            }
            for (key, value) in messages {
                let message = extractString(from: value)
                if key == "detail" || key == "non_field_errors" {
                    alert = AppAlert(title: "Error", message: message)
                } else {
                    fieldErrors[key] = message
                }
            }
        }

        private func extractString(from value: Any) -> String {
            if let arr = value as? NSArray {
                return arr.compactMap { $0 as? String }.joined(separator: "\n")
            }
            if let str = value as? String { return str }
            return "Unknown error"
        }
    }
}
