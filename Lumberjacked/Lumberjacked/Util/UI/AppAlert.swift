//
//  AppAlert.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 6/5/26.
//

import SwiftUI

struct AppAlert: Identifiable {
    let id = UUID()
    var title: String
    var message: String? = nil
    var confirmAction: (() -> Void)? = nil
    var confirmLabel: String = "Confirm"
    var cancelLabel: String = "Cancel"
    var dismissLabel: String = "OK"
    var destructiveAction: (() -> Void)? = nil
    var destructiveLabel: String = "Delete"
}

extension View {
    func alert(item: Binding<AppAlert?>) -> some View {
        let a = item.wrappedValue
        let dismiss = { item.wrappedValue = nil }
        return self.alert(
            a?.title ?? "",
            isPresented: Binding(get: { a != nil }, set: { if !$0 { dismiss() } })
        ) {
            if let confirm = a?.confirmAction {
                Button(a?.confirmLabel ?? "Confirm") { confirm(); dismiss() }
                if let destructive = a?.destructiveAction {
                    Button(a?.destructiveLabel ?? "Delete", role: .destructive) { destructive(); dismiss() }
                }
                Button(a?.cancelLabel ?? "Cancel", role: .cancel) { dismiss() }
            } else {
                Button(a?.dismissLabel ?? "OK") { dismiss() }
            }
        } message: {
            if let msg = a?.message { Text(msg) }
        }
    }
}
