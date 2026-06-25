//
//  UnsavedChangesState.swift
//  Lumberjacked
//

import SwiftUI

/// Shared environment object that lets any editable detail view register its
/// save/discard actions so that ContentView can intercept tab switches, and
/// LumberjackedApp can schedule the "you forgot to save" notification.
///
/// You don't interact with this directly — just apply `.unsavedChangesGuard()`
/// to your view and it handles everything automatically.
@Observable
class UnsavedChangesState {
    var isDirty = false
    var saveAction: (() async -> Bool)?
    var discardAction: (() -> Void)?
}
