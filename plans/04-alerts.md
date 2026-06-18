# Plan 04: Alerts — AppAlert

## Goal
Replace individual alert boolean flags (`showCancelConfirmationAlert`, `showFinishWorkoutConfirmationAlert`, etc.) with a single `var alert: AppAlert?` on each ViewModel. Alerts are shown/dismissed by setting/clearing this property.

## Current State (flags to replace)

| File | Flag(s) |
|---|---|
| `CurrentWorkoutView+ViewModel.swift` | `showCancelConfirmationAlert`, `showFinishWorkoutConfirmationAlert` |
| `MovementSelectorView+ViewModel.swift` | `showCreateMovementSheet` (this is a sheet, not an alert — keep as-is) |
| `MovementCatalogView+ViewModel.swift` | `showCreateMovementSheet` (sheet — keep as-is) |

Note: `showCreateWorkoutSheet` and `showAddMovementOverlay` in `CurrentWorkoutView` are sheet/overlay toggles, not alerts. Keep those as booleans since `AppAlert` is specifically for `.alert()` modifiers, not `.sheet()`.

## New File to Create

### `Lumberjacked/Utilities/AppAlert.swift`

```swift
import SwiftUI

struct AppAlert: Identifiable {
    let id = UUID()
    var title: String
    var message: String? = nil
    var confirmAction: (() -> Void)? = nil
    var confirmLabel: String = "Confirm"
    var cancelLabel: String = "Cancel"
    var dismissLabel: String = "OK"
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
                Button(a?.cancelLabel ?? "Cancel", role: .cancel) { dismiss() }
            } else {
                Button(a?.dismissLabel ?? "OK") { dismiss() }
            }
        } message: {
            if let msg = a?.message { Text(msg) }
        }
    }
}
```

## Implementation Steps

### CurrentWorkoutView+ViewModel.swift

1. Remove `var showCancelConfirmationAlert = false` and `var showFinishWorkoutConfirmationAlert = false`.
2. Add `var alert: AppAlert?`.
3. Where views set `showCancelConfirmationAlert = true`, instead set:
   ```swift
   viewModel.alert = AppAlert(
       title: "Cancel Workout",
       confirmAction: { Task { await self.attemptDeleteCurrentWorkout() } },
       confirmLabel: "Yes",
       cancelLabel: "No"
   )
   ```
4. Where views set `showFinishWorkoutConfirmationAlert = true`, instead set:
   ```swift
   viewModel.alert = AppAlert(
       title: "Finish Workout",
       message: "If you haven't recorded a log for a movement it will be marked as skipped.",
       confirmAction: { Task { await self.attemptEndCurrentWorkout() } },
       confirmLabel: "Save Workout",
       cancelLabel: "Cancel"
   )
   ```
   Note: The "Discard Workout" option is a third action not covered by AppAlert's binary confirm/cancel. Keep this alert as a bespoke `.alert` modifier OR extend `AppAlert` to support a destructive secondary action. Recommended: add a `destructiveAction`/`destructiveLabel` pair to `AppAlert`.

### All other ViewModels

Add `var alert: AppAlert?` to all ViewModels even if not currently used for alerts — the architecture requires this field, and it will be populated by error handling in Plan 05.

## View Callsite Updates

In `CurrentWorkoutView.swift`:
- Remove `.alert("Cancel Workout", isPresented: $viewModel.showCancelConfirmationAlert) { ... }`.
- Remove `.alert("Finish Workout", isPresented: $viewModel.showFinishWorkoutConfirmationAlert) { ... }`.
- Add single `.alert(item: $viewModel.alert)`.

## Test Plan

After changes:
1. Run `xcodebuild build`.
2. Run `xcodebuild test`.
3. Manually verify: cancel workout alert shows and cancels correctly; finish workout alert shows with all three options.
4. Unit test: set alert = AppAlert(title: "Test") → assert alert != nil; call dismiss closure → assert alert == nil.
