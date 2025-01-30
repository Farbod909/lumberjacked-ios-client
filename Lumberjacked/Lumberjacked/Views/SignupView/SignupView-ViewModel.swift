//
//  SignupView-ViewModel.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/21/25.
//

import SwiftUI

extension SignupView {
    @Observable
    class ViewModel {
        var email = ""
        var password1 = ""
        var password2 = ""

        var isLoadingToolbarAction = false
        
        func attemptSignup(errors: Binding<LumberjackedClientErrors>) async -> Bool {
            isLoadingToolbarAction = true
            
            if let response = await LumberjackedClient(errors: errors)
                .signup(email: email, password1: password1, password2: password2) {
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
