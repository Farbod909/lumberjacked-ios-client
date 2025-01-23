//
//  LumberjackedApp.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/21/25.
//

import SwiftUI

@main
struct LumberjackedApp: App {
    @StateObject var appEnvironment = LumberjackedAppEnvironment()
        
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    appEnvironment.evaluateAuthenticationStatus()
                }
                .sheet(isPresented: $appEnvironment.isNotAuthenticated) {
                    AuthView()
                }
                .environmentObject(appEnvironment)
                .alert(appEnvironment.alertMessage, isPresented: $appEnvironment.showAlert) {
                    Button("OK") { }
                }
        }
    }
}
