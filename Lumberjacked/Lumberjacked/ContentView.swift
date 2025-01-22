//
//  ContentView.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/21/25.
//

import SwiftUI

struct ContentView: View {
    @State var viewModel = ViewModel()
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "list.clipboard")
                }
            CatalogView()
                .tabItem {
                    Label("Exercise Catalog", systemImage: "book.closed")
                }
            HistoryView()
                .tabItem {
                    Label("Workout History", systemImage: "calendar")
                }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "line.3.horizontal")
                }
        }
    }
}

#Preview {
    ContentView()
}
