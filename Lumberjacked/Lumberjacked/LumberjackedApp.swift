//
//  LumberjackedApp.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/21/25.
//

import SwiftUI

@main
struct LumberjackedApp: App {
    @State var appModel = LumberjackedAppModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    appModel.evaluateAuthenticationStatus()
                }
                .sheet(isPresented: $appModel.isNotAuthenticated) {
                    AuthView()
                }
                .environment(appModel)
        }
    }
}
