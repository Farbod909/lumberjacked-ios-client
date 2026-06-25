//
//  ContentView.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/21/25.
//

import SwiftUI

struct ContentView: View {
    @State var viewModel = ViewModel()
    @AppStorage("colorSchemePreference") private var colorSchemePreference: String = "dark"
    @Environment(UnsavedChangesState.self) private var unsavedChangesState
    @State private var selectedTab = 0
    @State private var pendingTab: Int? = nil
    @State private var showTabSwitchAlert = false

    var preferredColorScheme: ColorScheme? {
        switch colorSchemePreference {
        case "light":  return .light
        case "dark":   return .dark
        default:       return nil
        }
    }

    // Custom binding so the tab never actually changes when there are unsaved changes.
    // Using onChange + revert is unreliable — SwiftUI may render the new tab before
    // the revert takes effect, causing onDisappear to fire and clear the dirty state.
    private var tabSelection: Binding<Int> {
        Binding(
            get: { selectedTab },
            set: { newTab in
                guard unsavedChangesState.isDirty else {
                    selectedTab = newTab
                    return
                }
                pendingTab = newTab
                showTabSwitchAlert = true
                // selectedTab is intentionally not updated — tab stays put.
            }
        )
    }

    var body: some View {
        TabView(selection: tabSelection) {
            CurrentWorkoutView()
                .tabItem { Label("Home", systemImage: "list.clipboard") }
                .tag(0)
            MovementCatalogView()
                .tabItem { Label("Catalog", systemImage: "book.closed") }
                .tag(1)
            WorkoutHistoryView()
                .tabItem { Label("History", systemImage: "calendar") }
                .tag(2)
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
                .tag(3)
        }
        .alert("Unsaved Changes", isPresented: $showTabSwitchAlert) {
            Button("Save") {
                Task {
                    let saved = await unsavedChangesState.saveAction?() ?? false
                    guard saved else { return }
                    unsavedChangesState.isDirty = false
                    if let tab = pendingTab { selectedTab = tab }
                    pendingTab = nil
                }
            }
            Button("Discard", role: .destructive) {
                unsavedChangesState.discardAction?()
                unsavedChangesState.isDirty = false
                if let tab = pendingTab { selectedTab = tab }
                pendingTab = nil
            }
            Button("Keep Editing", role: .cancel) {
                pendingTab = nil
            }
        } message: {
            Text("Would you like to save your changes before leaving?")
        }
        .preferredColorScheme(preferredColorScheme)
    }
}

#if DEBUG
#Preview {
    ContentView()
        .environmentObject(LumberjackedAppEnvironment())
}
#endif
