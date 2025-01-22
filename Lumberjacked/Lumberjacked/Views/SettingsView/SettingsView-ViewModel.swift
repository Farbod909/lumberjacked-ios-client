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
        func attemptLogout() async {
            if await NetworkingRequest(
                options: Networking.RequestOptions(url: "/auth/logout/", method: .POST)
            ).attempt() {
                Keychain.standard.delete(service: "accessToken", account: "lumberjacked")
            }
        }
    }
}
