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

    @State private var showRestTimerPicker = false
    @State private var pickerMinutes: Int = 2
    @State private var pickerSeconds: Int = 0

    private var formattedDefaultRest: String {
        String(format: "%d:%02d", defaultRestTime / 60, defaultRestTime % 60)
    }

    init(viewModel: ViewModel = ViewModel()) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Form {
            Section("Workouts") {
                HStack {
                    Text("Default Rest Time")
                    Spacer()
                    Button {
                        pickerMinutes = defaultRestTime / 60
                        pickerSeconds = (defaultRestTime % 60 / 10) * 10
                        showRestTimerPicker = true
                    } label: {
                        Text(formattedDefaultRest)
                            .monospacedDigit()
                            .foregroundStyle(Color.brandPrimaryText)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(Color.brandSecondaryLight))
                    }
                    .buttonStyle(.borderless)
                    .popover(isPresented: $showRestTimerPicker) {
                        VStack(spacing: 12) {
                            HStack(spacing: 0) {
                                Picker("Minutes", selection: $pickerMinutes) {
                                    ForEach(0...10, id: \.self) { Text("\($0)m") }
                                }
                                .pickerStyle(.wheel)
                                .frame(width: 100)
                                .clipped()

                                Picker("Seconds", selection: $pickerSeconds) {
                                    ForEach([0, 10, 20, 30, 40, 50], id: \.self) { Text("\($0)s") }
                                }
                                .pickerStyle(.wheel)
                                .frame(width: 100)
                                .clipped()
                            }
                            Button("Set") {
                                defaultRestTime = pickerMinutes * 60 + pickerSeconds
                                showRestTimerPicker = false
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(pickerMinutes == 0 && pickerSeconds == 0)
                            .padding(.bottom, 8)
                        }
                        .padding(.top, 8)
                        .presentationCompactAdaptation(.popover)
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
