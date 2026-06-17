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

    var preferredColorScheme: ColorScheme? {
        switch colorSchemePreference {
        case "light":  return .light
        case "dark":   return .dark
        default:       return nil
        }
    }

    var body: some View {
        TabView {
            CurrentWorkoutView()
                .tabItem {
                    Label("Home", systemImage: "list.clipboard")
                }
            MovementCatalogView()
                .tabItem {
                    Label("Catalog", systemImage: "book.closed")
                }
            WorkoutHistoryView()
                .tabItem {
                    Label("History", systemImage: "calendar")
                }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
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
