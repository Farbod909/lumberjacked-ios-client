//
//  SettingsView.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/21/25.
//

import SwiftUI

struct SettingsView: View {
    @State var viewModel: ViewModel
    @EnvironmentObject var appEnvironment: LumberjackedAppEnvironment

    init(viewModel: ViewModel = ViewModel()) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Form {
            Section {
                Button("Log out") {
                    Task {
                        await viewModel.attemptLogout()
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

#if DEBUG
#Preview {
    SettingsView(viewModel: SettingsView.ViewModel(api: MockAuthAPI()))
        .environmentObject(LumberjackedAppEnvironment())
}
#endif
