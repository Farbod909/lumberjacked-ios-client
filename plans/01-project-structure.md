# Plan 01: Project Structure — ViewModel File Naming

## Goal
Rename all `*-ViewModel.swift` files to `*+ViewModel.swift` to match Swift ecosystem conventions (the `+` signals it is an extension file).

## Files to Rename (15 total)

| From | To |
|---|---|
| `ContentView-ViewModel.swift` | `ContentView+ViewModel.swift` |
| `Views/AuthView/AuthView-ViewModel.swift` | `Views/AuthView/AuthView+ViewModel.swift` |
| `Views/CreateWorkoutView/CreateWorkoutView-ViewModel.swift` | `Views/CreateWorkoutView/CreateWorkoutView+ViewModel.swift` |
| `Views/CurrentWorkoutView/CurrentWorkoutView-ViewModel.swift` | `Views/CurrentWorkoutView/CurrentWorkoutView+ViewModel.swift` |
| `Views/LoginView/LoginView-ViewModel.swift` | `Views/LoginView/LoginView+ViewModel.swift` |
| `Views/MovementCatalogView/MovementCatalogView-ViewModel.swift` | `Views/MovementCatalogView/MovementCatalogView+ViewModel.swift` |
| `Views/MovementDetailView/MovementDetailView-ViewModel.swift` | `Views/MovementDetailView/MovementDetailView+ViewModel.swift` |
| `Views/MovementInputView/MovementInputView-ViewModel.swift` | `Views/MovementInputView/MovementInputView+ViewModel.swift` |
| `Views/MovementLogInputView/MovementLogInputView-ViewModel.swift` | `Views/MovementLogInputView/MovementLogInputView+ViewModel.swift` |
| `Views/MovementSelectorView/MovementSelectorView-ViewModel.swift` | `Views/MovementSelectorView/MovementSelectorView+ViewModel.swift` |
| `Views/SettingsView/SettingsView-ViewModel.swift` | `Views/SettingsView/SettingsView+ViewModel.swift` |
| `Views/SignupView/SignupView-ViewModel.swift` | `Views/SignupView/SignupView+ViewModel.swift` |
| `Views/TemplateWorkoutSelectorView/TemplateWorkoutSelectorView-ViewModel.swift` | `Views/TemplateWorkoutSelectorView/TemplateWorkoutSelectorView+ViewModel.swift` |
| `Views/WorkoutDetailView/WorkoutDetailView-ViewModel.swift` | `Views/WorkoutDetailView/WorkoutDetailView+ViewModel.swift` |
| `Views/WorkoutHistoryView/WorkoutHistoryView-ViewModel.swift` | `Views/WorkoutHistoryView/WorkoutHistoryView+ViewModel.swift` |

## Implementation Steps

1. Use `git mv` for each file to preserve git history.
2. No code changes required — Swift file names do not affect compilation or symbol resolution.
3. Xcode uses `PBXFileSystemSynchronizedRootGroup` so it auto-picks up renames without touching `.xcodeproj`.

## Notes

- Do NOT change any Swift code inside these files.
- Do NOT rename the view files themselves (`WorkoutListView.swift` stays).
- The `+` character is valid in macOS/Xcode file names.

## Test Plan

After renaming:
1. Run `xcodebuild build` to confirm all files compile.
2. Run `xcodebuild test` (unit + UI tests) to confirm nothing broke.
3. Verify no `-ViewModel.swift` files remain in the source tree.
