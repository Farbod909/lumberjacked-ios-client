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
        func attemptLogout(errors: Binding<LumberjackedClientErrors>) async {
            await LumberjackedClient(errors: errors).logout()
            Keychain.standard.delete(service: "accessToken", account: "lumberjacked")
        }
    }
}
