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
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
