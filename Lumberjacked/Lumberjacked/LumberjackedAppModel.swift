//
//  LumberjackedApp-ViewModel.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/22/25.
//

import SwiftUI

@Observable
class LumberjackedAppModel {
    var isNotAuthenticated = Keychain.standard.read(
        service: "accessToken", account: "lumberjacked") == nil
    
    func evaluateAuthenticationStatus() {
        isNotAuthenticated = Keychain.standard.read(
            service: "accessToken", account: "lumberjacked") == nil
    }
}
