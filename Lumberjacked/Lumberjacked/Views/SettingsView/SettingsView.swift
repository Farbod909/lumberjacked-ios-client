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
    @AppStorage("defaultWarmupRestTime") private var defaultWarmupRestTime: Int = 0
    @AppStorage("defaultDropsetRestTime") private var defaultDropsetRestTime: Int = 0
    @AppStorage("defaultMyorepsRestTime") private var defaultMyorepsRestTime: Int = 20
    @AppStorage("weightUnit") private var weightUnitRaw: String = WeightUnit.lb.rawValue

    private enum RestTimePickerTarget { case working, warmup, dropset, myoreps }
    @State private var pickerTarget: RestTimePickerTarget? = nil
    @State private var pickerMinutes: Int = 0
    @State private var pickerSeconds: Int = 0

    private func formattedTime(_ seconds: Int) -> String {
        String(format: "%d:%02d", seconds / 60, seconds % 60)
    }

    init(viewModel: ViewModel = ViewModel()) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Form {
            Section("Workouts") {
                Picker("Weight Unit", selection: $weightUnitRaw) {
                    Text("lbs").tag(WeightUnit.lb.rawValue)
                    Text("kg").tag(WeightUnit.kg.rawValue)
                }
                .pickerStyle(.segmented)
            }
            .listRowBackground(Color.brandSecondary)

            Section("Post-Set Rest") {
                restTimeRow("Working / Failure", seconds: defaultRestTime, target: .working)
                restTimeRow("Warmup", seconds: defaultWarmupRestTime, target: .warmup)
            }
            .listRowBackground(Color.brandSecondary)

            Section("Pre-Set Rest") {
                restTimeRow("Dropset", seconds: defaultDropsetRestTime, target: .dropset)
                restTimeRow("Myorep", seconds: defaultMyorepsRestTime, target: .myoreps)
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

    @ViewBuilder
    private func restTimeRow(_ label: String, seconds: Int, target: RestTimePickerTarget) -> some View {
        HStack {
            Text(label)
            Spacer()
            Button {
                pickerMinutes = seconds / 60
                pickerSeconds = (seconds % 60 / 10) * 10
                pickerTarget = target
            } label: {
                Text(formattedTime(seconds))
                    .monospacedDigit()
                    .foregroundStyle(Color.brandPrimaryText)
                    .padding(.horizontal, 16)
                    .frame(maxHeight: .infinity)
                    .background(Capsule().fill(Color.brandSecondaryLight))
            }
            .buttonStyle(.borderless)
            .popover(isPresented: Binding(
                get: { pickerTarget == target },
                set: { if !$0 { pickerTarget = nil } }
            )) {
                restTimePickerContent(for: target)
            }
        }
        .frame(maxHeight: .infinity)
        .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
    }

    @ViewBuilder
    private func restTimePickerContent(for target: RestTimePickerTarget) -> some View {
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
                let total = pickerMinutes * 60 + pickerSeconds
                switch target {
                case .working:  defaultRestTime = total
                case .warmup:   defaultWarmupRestTime = total
                case .dropset:  defaultDropsetRestTime = total
                case .myoreps:  defaultMyorepsRestTime = total
                }
                pickerTarget = nil
            }
            .buttonStyle(.borderedProminent)
            .padding(.bottom, 8)
        }
        .padding(.top, 8)
        .presentationCompactAdaptation(.popover)
    }
}

#if DEBUG
#Preview {
    SettingsView(viewModel: SettingsView.ViewModel(api: MockAuthAPI()))
        .environmentObject(LumberjackedAppEnvironment())
}
#endif
