//
//  SettingsView.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/21/25.
//

import SwiftUI

struct SettingsView: View {
    @State var viewModel = ViewModel()
    @State var errors = LumberjackedClientErrors()
    @EnvironmentObject var appEnvironment: LumberjackedAppEnvironment

    var body: some View {
        Form {
            Section {
                Button("Log out") {
                    Task {
                        await viewModel.attemptLogout(errors: $errors)
                        appEnvironment.evaluateAuthenticationStatus()
                    }
                }
            }
            .listRowBackground(Color.brandSecondary)
        }
        .scrollContentBackground(.hidden)
        .background(Color.brandBackground.ignoresSafeArea())
    }
}

#Preview {
    SettingsView()
}
