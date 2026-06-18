# Plan 05: Error Handling — fieldErrors + FieldErrorModifier

## Goal
Replace `LumberjackedClientErrors` (a struct with an opaque `[String: Any]` dict and complex extraction logic) with:
- `var fieldErrors: [String: String] = [:]` on form ViewModels (field-level validation errors)  
- `var alert: AppAlert?` for general/network errors (already added in Plan 04)
- A new `FieldErrorModifier` using a clean `.fieldError(String?)` API

This eliminates the `NSArray`-bridging complexity in `LumberjackedClientErrors` and the dual-purpose nature of the old `errors` struct.

## Current Files to Replace/Remove

- `Lumberjacked/Util/Networking/LumberjackedClient.swift` — contains `LumberjackedClientErrors` struct and inline request helper methods (`LumberjackedClientActionRequest`, etc.). The struct will be deleted; the request methods will be left or moved to networking layer.
- `Lumberjacked/Util/UI/FormFieldError.swift` — existing modifier backed by `LumberjackedClientErrors`. Will be replaced.
- `Lumberjacked/Util/UI/FormErrors.swift` — existing component that shows `detail` + `non_field_errors` from `LumberjackedClientErrors`. Will be deleted (replaced by `AppAlert` from Plan 04).

## New File to Create

### `Lumberjacked/Utilities/FieldErrorModifier.swift`

```swift
import SwiftUI

struct FieldErrorModifier: ViewModifier {
    let message: String?

    func body(content: Content) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            content
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(message != nil ? Color.red : Color.clear, lineWidth: 1)
                )
            if let message {
                Text(message)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
}

extension View {
    func fieldError(_ message: String?) -> some View {
        modifier(FieldErrorModifier(message: message))
    }
}
```

## ViewModel Changes

### ViewModels with form submission (replace `errors` with `fieldErrors`)

| File | Fields |
|---|---|
| `LoginView+ViewModel.swift` | `email`, `password` |
| `SignupView+ViewModel.swift` | `email`, `password1`, `password2` |
| `MovementInputView+ViewModel.swift` | `name`, `category`, `notes`, `recommended_*` |
| `MovementLogInputView+ViewModel.swift` | form fields |
| `MovementSelectorView+ViewModel.swift` | general errors only |

For each:
1. Remove `var errors = LumberjackedClientErrors()`.
2. Add `var fieldErrors: [String: String] = [:]`.
3. At top of submit function: `fieldErrors = [:]`.
4. In catch block for `RemoteNetworkingError`:
   - Field errors (keyed by field name) → populate `fieldErrors[key] = message`.
   - General errors (`detail`, `non_field_errors`) → set `alert = AppAlert(title: "Error", message: message)`.
5. Other errors → `alert = AppAlert(title: "Error", message: error.localizedDescription)`.

### ViewModels without forms (no field errors)

| File | Change |
|---|---|
| `CurrentWorkoutView+ViewModel.swift` | Remove `var errors`, errors → `alert` only |
| `MovementDetailView+ViewModel.swift` | Same |
| `WorkoutDetailView+ViewModel.swift` | Same |
| `WorkoutHistoryView+ViewModel.swift` | Same |
| `MovementCatalogView+ViewModel.swift` | Same |
| `TemplateWorkoutSelectorView+ViewModel.swift` | Same |
| `SettingsView+ViewModel.swift` | Same |
| `CreateWorkoutView+ViewModel.swift` | Same |

For each: remove `var errors = LumberjackedClientErrors()`. Errors route to `alert` (added in Plan 04).

## View Callsite Changes

### LoginView.swift
```swift
// Before:
TextField("Email", text: $viewModel.email)
    .formFieldError($viewModel.errors, "email")

// After:
TextField("Email", text: $viewModel.email)
    .fieldError(viewModel.fieldErrors["email"])
```

### SignupView.swift, MovementInputView.swift
Same pattern — replace `.formFieldError($viewModel.errors, "key")` with `.fieldError(viewModel.fieldErrors["key"])`.

Remove all `FormErrors(errors: $viewModel.errors)` — general errors are now shown via `.alert(item: $viewModel.alert)`.

## Error Mapping from RemoteNetworkingError

`RemoteNetworkingError` has `messages: [String: Any]?`. The extraction logic in `LumberjackedClientErrors` will be moved to a helper in the ViewModel catch block or a static utility:

```swift
func handleNetworkError(_ error: RemoteNetworkingError) {
    guard let messages = error.messages else {
        alert = AppAlert(title: "Error", message: "Unknown error")
        return
    }
    for (key, value) in messages {
        let message = extractString(from: value)
        if key == "detail" || key == "non_field_errors" {
            alert = AppAlert(title: "Error", message: message)
        } else {
            fieldErrors[key] = message
        }
    }
}

private func extractString(from value: Any) -> String {
    if let arr = value as? NSArray {
        return arr.compactMap { $0 as? String }.joined(separator: "\n")
    }
    if let str = value as? String { return str }
    return "Unknown error"
}
```

This helper can live in a `ViewModel+ErrorHandling.swift` extension or be inlined per ViewModel.

## Test Plan

After changes:
1. `xcodebuild build` — must compile with no errors.
2. `xcodebuild test` — all unit tests in `LumberjackedClientErrorsTests` must still pass (those tests should be updated to test the new `fieldErrors` extraction logic directly).
3. Manual: submit login form with bad credentials — field errors appear under correct fields.
4. Manual: trigger network error — alert pops up with message.
5. Unit test: `LoginView.ViewModel` with mock throwing `RemoteNetworkingError(messages: ["email": ["Invalid email"]])` → assert `fieldErrors["email"] == "Invalid email"`.
