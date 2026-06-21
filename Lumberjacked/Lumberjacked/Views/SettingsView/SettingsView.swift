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
    @AppStorage("colorSchemePreference") private var colorSchemePreference: String = "dark"
    @AppStorage("useLocalBackend") private var useLocalBackend: Bool = false
    @AppStorage("defaultRestTime") private var defaultRestTime: Int = 120

    private func formattedRestTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }

    init(viewModel: ViewModel = ViewModel()) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Form {
            Section("Workouts") {
                Stepper(value: $defaultRestTime, in: 30...600, step: 30) {
                    HStack {
                        Text("Default Rest Time")
                        Spacer()
                        Text(formattedRestTime(defaultRestTime))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .listRowBackground(Color.brandSecondary)

            Section("Appearance") {
                Picker("Theme", selection: $colorSchemePreference) {
                    Text("System").tag("system")
                    Text("Light").tag("light")
                    Text("Dark").tag("dark")
                }
                .pickerStyle(.segmented)
            }
            .listRowBackground(Color.brandSecondary)

            Section("Backend") {
                Picker("Server", selection: $useLocalBackend) {
                    Text("Remote").tag(false)
                    Text("Local").tag(true)
                }
                .pickerStyle(.segmented)
                .onChange(of: useLocalBackend) {
                    Task {
                        await viewModel.attemptLogout()
                        appEnvironment.evaluateAuthenticationStatus()
                    }
                }

                Text(useLocalBackend ? NetworkConfiguration.localURL : NetworkConfiguration.remoteURL)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .listRowBackground(Color.brandSecondary)

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
