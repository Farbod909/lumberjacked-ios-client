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
        
        func attemptLogin(errors: Binding<LumberjackedClientErrors>) async -> Bool {
            isLoadingToolbarAction = true
            
            if let response = await LumberjackedClient(errors: errors)
                .login(email: email, password: password) {
                Keychain.standard.save(
                    response.key, service: "accessToken", account: "lumberjacked")
                isLoadingToolbarAction = false
                return true
            }

            isLoadingToolbarAction = false
            return false
        }

    }
}
