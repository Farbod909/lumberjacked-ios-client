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
        
        func attemptLogin() async -> Bool {
            isLoadingToolbarAction = true

            let loginRequest = LoginRequest(email: email, password: password)
            if let response = await NetworkingRequest(
                options: Networking.RequestOptions(
                    url: "/auth/login/",
                    body: loginRequest,
                    method: .POST,
                    headers: [
                        ("application/json", "Content-Type")
                    ])
            ).attempt(outputType: LoginResponse.self) {
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
