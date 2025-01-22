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
        
        func attemptSignup() async -> Bool {
            isLoadingToolbarAction = true

            let signupRequest = SignupRequest(
                email: email, password1: password1, password2: password2)
            if let response = await NetworkingRequest(
                options: Networking.RequestOptions(
                    url: "/auth/registration/",
                    body: signupRequest,
                    method: .POST,
                    headers: [
                        ("application/json", "Content-Type")
                    ])
            ).attempt(outputType: SignupResponse.self) {
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
