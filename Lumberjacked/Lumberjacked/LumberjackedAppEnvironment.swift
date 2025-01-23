//
//  LumberjackedApp-ViewModel.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/22/25.
//

import SwiftUI


class LumberjackedAppEnvironment: ObservableObject {
    @Published var isNotAuthenticated = Keychain.standard.read(
        service: "accessToken", account: "lumberjacked") == nil
    
    @Published var showAlert = false
    @Published var alertMessage = ""
    
    func evaluateAuthenticationStatus() {
        isNotAuthenticated = Keychain.standard.read(
            service: "accessToken", account: "lumberjacked") == nil
    }
}
