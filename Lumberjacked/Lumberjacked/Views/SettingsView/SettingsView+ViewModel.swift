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
        var errors = LumberjackedClientErrors()

        private let api: AuthAPIProtocol

        init(api: AuthAPIProtocol = LiveAuthAPI()) {
            self.api = api
        }

        func attemptLogout() async {
            errors.messages = [:]
            do {
                try await api.logout()
            } catch let error as RemoteNetworkingError {
                if let messages = error.messages {
                    errors.messages = messages
                } else {
                    errors.messages["detail"] = "Unknown error"
                }
            } catch {
                errors.messages["detail"] = "Unknown error"
            }
            Keychain.standard.delete(service: "accessToken", account: "lumberjacked")
        }
    }
}
