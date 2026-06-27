//
//  LumberjackedApp.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/21/25.
//

import SwiftUI
import UserNotifications

@main
struct LumberjackedApp: App {
    @StateObject var appEnvironment = LumberjackedAppEnvironment()
    @State private var restTimer = RestTimerEnvironment()
    @State private var unsavedChangesState = UnsavedChangesState()
    @Environment(\.scenePhase) private var scenePhase

    private let unsavedChangesNotificationID = "unsaved-workout-changes"
    private let unfinishedWorkoutNotificationID = "unfinished-workout"

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
                .environment(restTimer)
                .environment(unsavedChangesState)
                .alert(appEnvironment.alertMessage, isPresented: $appEnvironment.showAlert) {
                    Button("OK") { }
                }
        }
        .onChange(of: scenePhase) { _, phase in
            switch phase {
            case .background:
                if unsavedChangesState.isDirty {
                    scheduleUnsavedChangesNotification()
                }
                if appEnvironment.hasActiveWorkout {
                    scheduleUnfinishedWorkoutNotification()
                }
            case .active:
                cancelUnsavedChangesNotification()
                cancelUnfinishedWorkoutNotification()
            default:
                break
            }
        }
    }

    private func scheduleUnsavedChangesNotification() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            guard granted else { return }
            let content = UNMutableNotificationContent()
            content.title = "Unsaved changes"
            content.body = "You forgot to save your changes!"
            content.sound = .default
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
            let request = UNNotificationRequest(
                identifier: unsavedChangesNotificationID,
                content: content,
                trigger: trigger
            )
            center.add(request)
        }
    }

    private func cancelUnsavedChangesNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [unsavedChangesNotificationID]
        )
    }

    private func scheduleUnfinishedWorkoutNotification() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            guard granted else { return }
            let content = UNMutableNotificationContent()
            content.title = "Unfinished workout"
            content.body = "Did you forget to end your workout?"
            content.sound = .default
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 30 * 60, repeats: false)
            let request = UNNotificationRequest(
                identifier: unfinishedWorkoutNotificationID,
                content: content,
                trigger: trigger
            )
            center.add(request)
        }
    }

    private func cancelUnfinishedWorkoutNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [unfinishedWorkoutNotificationID]
        )
    }
}
