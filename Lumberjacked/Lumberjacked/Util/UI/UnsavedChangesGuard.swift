//
//  UnsavedChangesGuard.swift
//  Lumberjacked
//

import SwiftUI

// MARK: - Modifier

private struct UnsavedChangesGuardModifier: ViewModifier {
    let isDirty: Bool
    let save: () async -> Void
    let discard: () -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(UnsavedChangesState.self) private var unsavedChangesState
    @State private var showAlert = false

    func body(content: Content) -> some View {
        content
            // Intercepts swipe-back when dirty; allows it when clean.
            .background(
                NavigationBackInterceptor(isDirty: isDirty) { showAlert = true }
            )
            // Always hide the system back button so there's no animation when
            // isDirty changes; our custom button below handles both states.
            .navigationBarBackButtonHidden(true)
            .onAppear {
                unsavedChangesState.isDirty = isDirty
                unsavedChangesState.saveAction = save
                unsavedChangesState.discardAction = discard
            }
            .onDisappear {
                unsavedChangesState.isDirty = false
                unsavedChangesState.saveAction = nil
                unsavedChangesState.discardAction = nil
            }
            .onChange(of: isDirty) { _, dirty in
                unsavedChangesState.isDirty = dirty
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        if isDirty { showAlert = true } else { dismiss() }
                    } label: {
                        Image(systemName: "chevron.backward")
                            .fontWeight(.semibold)
                    }
                }
            }
            .alert("Unsaved Changes", isPresented: $showAlert) {
                Button("Save") {
                    Task { await save(); dismiss() }
                }
                Button("Discard", role: .destructive) {
                    discard(); dismiss()
                }
                Button("Keep Editing", role: .cancel) {}
            } message: {
                Text("Would you like to save your changes before leaving?")
            }
    }
}

// MARK: - View extension

extension View {
    /// Adds full unsaved-changes protection to a pushed detail view:
    ///
    /// - Custom back button (no system-button animation flicker).
    /// - Swipe-back interception when dirty via `NavigationBackInterceptor`.
    /// - Tab-switch interception via `UnsavedChangesState` (managed by `ContentView`).
    /// - "You forgot to save" notification via `LumberjackedApp` scene-phase observer.
    ///
    /// **To wire up a new editable detail view (e.g. MovementDetailView):**
    /// 1. Add an `isDirty: Bool` computed property to the view's ViewModel.
    /// 2. Add a `resetChanges()` method that restores editable state from the
    ///    server-sourced model (see `WorkoutDetailView.ViewModel.resetChanges()`).
    /// 3. Apply this modifier once on the view's body:
    ///    ```swift
    ///    .unsavedChangesGuard(
    ///        isDirty: viewModel.isDirty,
    ///        save:    { await viewModel.attemptSaveChanges() },
    ///        discard: { viewModel.resetChanges() }
    ///    )
    ///    ```
    ///    That's all — the back button, swipe gesture, tab-switch alert, and
    ///    background notification are handled automatically.
    func unsavedChangesGuard(
        isDirty: Bool,
        save: @escaping () async -> Void,
        discard: @escaping () -> Void
    ) -> some View {
        modifier(UnsavedChangesGuardModifier(isDirty: isDirty, save: save, discard: discard))
    }
}
