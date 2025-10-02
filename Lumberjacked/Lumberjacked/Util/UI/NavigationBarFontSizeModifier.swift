//
//  NavigationBarFontSizeModifier.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 10/1/25.
//

import SwiftUI

struct NavigationBarFontSizeModifier: ViewModifier {
    init(fontSize: Double) {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.largeTitleTextAttributes = [.font: UIFont.systemFont(ofSize: fontSize)]
        navBarAppearance.titleTextAttributes = [.font: UIFont.systemFont(ofSize: fontSize)]
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
    }

    func body(content: Content) -> some View {
        content
    }
}

extension View {
    func navigationBarFontSizeModifier(fontSize: Double) -> some View {
        modifier(NavigationBarFontSizeModifier(fontSize: fontSize))
    }
}
