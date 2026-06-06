//
//  SettingsView-ViewModel.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/21/25.
//

import SwiftUI

extension SettingsView {
    @Observable
    class ViewModel {
        var alert: AppAlert?

        private let api: AuthAPIProtocol

        init(api: AuthAPIProtocol = LiveAuthAPI()) {
            self.api = api
        }

        func attemptLogout() async {
            do {
                try await api.logout()
            } catch let error as RemoteNetworkingError {
                handleNetworkError(error)
            } catch {
                alert = AppAlert(title: "Error", message: error.localizedDescription)
            }
            Keychain.standard.delete(service: "accessToken", account: "lumberjacked")
        }

        private func handleNetworkError(_ error: RemoteNetworkingError) {
            guard let messages = error.messages else {
                alert = AppAlert(title: "Error", message: "Unknown error")
                return
            }
            let msg = messages.values.compactMap { value -> String? in
                if let arr = value as? NSArray {
                    return arr.compactMap { $0 as? String }.joined(separator: "\n")
                }
                return value as? String
            }.joined(separator: "\n")
            alert = AppAlert(title: "Error", message: msg.isEmpty ? "Unknown error" : msg)
        }
    }
}
