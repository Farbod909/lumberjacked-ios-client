# Plan 02: ViewModel Pattern — @MainActor + final

## Goal
Apply `@MainActor` at the class level on all ViewModels (instead of only on individual methods), and mark every ViewModel `final`. This ensures all property mutations are guaranteed to run on the main thread and enables compiler optimizations.

## Current State

All ViewModels are `@Observable class ViewModel` (not `final`, no class-level `@MainActor`). Some have `@MainActor` on individual async methods. The target pattern from the architecture doc is:

```swift
@MainActor
@Observable
final class ViewModel { ... }
```

## Files to Change (15 ViewModels)

All files at paths matching `*+ViewModel.swift` (after Plan 01 rename, or `-ViewModel.swift` if done before Plan 01):

- `ContentView+ViewModel.swift`
- `AuthView+ViewModel.swift`
- `CreateWorkoutView+ViewModel.swift`
- `CurrentWorkoutView+ViewModel.swift`
- `LoginView+ViewModel.swift`
- `MovementCatalogView+ViewModel.swift`
- `MovementDetailView+ViewModel.swift`
- `MovementInputView+ViewModel.swift`
- `MovementLogInputView+ViewModel.swift`
- `MovementSelectorView+ViewModel.swift`
- `SettingsView+ViewModel.swift`
- `SignupView+ViewModel.swift`
- `TemplateWorkoutSelectorView+ViewModel.swift`
- `WorkoutDetailView+ViewModel.swift`
- `WorkoutHistoryView+ViewModel.swift`

## Implementation Steps

For each ViewModel file:

1. Add `@MainActor` on the line immediately before `@Observable`.
2. Add `final` before `class ViewModel`.
3. Remove any `@MainActor` annotations that were on individual methods (they become redundant at class level).
4. Example transformation:

```swift
// Before:
@Observable
class ViewModel {
    @MainActor
    func save() async { ... }
}

// After:
@MainActor
@Observable
final class ViewModel {
    func save() async { ... }
}
```

## Potential Issues

- If any subclass currently inherits from a ViewModel, `final` would break it. Survey: no ViewModel subclasses exist in this project.
- With `@MainActor` on the class, any call to a ViewModel method from a non-isolated context (e.g., a background actor) will need `await`. Check call sites in view `.task` blocks — SwiftUI `.task` runs on the main actor already, so no change needed.
- `async throws` functions on a `@MainActor` class are still allowed.

## Test Plan

After changes:
1. Run `xcodebuild build` — must compile without errors.
2. Run `xcodebuild test` — all existing unit + UI tests must pass.
3. Search for any remaining per-method `@MainActor` annotations and remove any that are now redundant.
