# Plan 03: Loading State — LoadingTrackable

## Goal
Replace all ad-hoc boolean loading flags with a typed `LoadingKey` enum + `LoadingTrackable` protocol. This lets individual UI controls show spinners independently rather than sharing one boolean.

## Current State (flags to replace)

| File | Flag(s) |
|---|---|
| `CurrentWorkoutView+ViewModel.swift` | `isLoadingCurrentWorkout`, `isLoadingMovements` |
| `MovementSelectorView+ViewModel.swift` | `isLoading`, `isLoadingToolbarAction` |
| `MovementCatalogView+ViewModel.swift` | `isLoading` |
| `WorkoutHistoryView+ViewModel.swift` | `isLoading` |
| `TemplateWorkoutSelectorView+ViewModel.swift` | `isLoading` |
| `MovementDetailView+ViewModel.swift` | `isLoadingMovementLogs` |
| `LoginView+ViewModel.swift` | `isLoadingToolbarAction` |
| `SignupView+ViewModel.swift` | `isLoadingToolbarAction` |
| `CreateWorkoutView+ViewModel.swift` | `isLoadingToolbarAction` |

## New Files to Create

### `Lumberjacked/Utilities/LoadingTrackable.swift`

```swift
protocol LoadingTrackable: AnyObject {
    associatedtype LoadingKey: Hashable
    var loadingKeys: Set<LoadingKey> { get set }
}

extension LoadingTrackable {
    func isLoading(_ key: LoadingKey) -> Bool {
        loadingKeys.contains(key)
    }

    func withLoading(_ key: LoadingKey, action: () async throws -> Void) async throws {
        loadingKeys.insert(key)
        defer { loadingKeys.remove(key) }
        try await action()
    }
}
```

### `Lumberjacked/Utilities/LoadingButton.swift`

```swift
import SwiftUI

struct LoadingButton: View {
    let label: String
    let isLoading: Bool
    let action: () async -> Void

    var body: some View {
        Button {
            Task { await action() }
        } label: {
            ZStack {
                Text(label).opacity(isLoading ? 0 : 1)
                if isLoading { ProgressView() }
            }
        }
        .disabled(isLoading)
    }
}
```

## Implementation Steps Per ViewModel

For each ViewModel:

1. Add `LoadingTrackable` conformance.
2. Add `var loadingKeys: Set<LoadingKey> = []`.
3. Define a `LoadingKey` enum with cases matching the operations (e.g., `.load`, `.submit`, `.delete`).
4. Remove all boolean loading `var` properties.
5. Wrap async operations with `try? await withLoading(.caseKey) { ... }`.
6. Update view references: replace `viewModel.isLoading` with `viewModel.isLoading(.load)`, etc.

### Example: WorkoutHistoryView+ViewModel.swift

```swift
// Before:
var isLoading = true
func attemptGetWorkouts() async {
    isLoading = true
    // ...
    isLoading = false
}

// After:
var loadingKeys: Set<LoadingKey> = []
enum LoadingKey { case load }

func attemptGetWorkouts() async {
    try? await withLoading(.load) {
        // ...
    }
}
```

### Example: CurrentWorkoutView+ViewModel.swift

LoadingKeys: `.currentWorkout`, `.movements`, `.addMovement`, `.endWorkout`, `.deleteWorkout`

Remove: `isLoadingCurrentWorkout`, `isLoadingMovements`

### Example: MovementSelectorView+ViewModel.swift

LoadingKeys: `.movements`, `.action` (for toolbar save/create)

Remove: `isLoading`, `isLoadingToolbarAction`

## View Callsite Updates

Wherever views read the old boolean flags, update to use the typed check:
- `viewModel.isLoading` → `viewModel.isLoading(.load)`
- `viewModel.isLoadingToolbarAction` → `viewModel.isLoading(.action)` (or `.submit`)
- `viewModel.isLoadingCurrentWorkout` → `viewModel.isLoading(.currentWorkout)`
- `viewModel.isLoadingMovements` → `viewModel.isLoading(.movements)`

For toolbar buttons that showed `ProgressView()` when loading, use `LoadingButton` where appropriate, or keep inline `if viewModel.isLoading(.submit) { ProgressView() } else { Text("Save") }`.

## Test Plan

After changes:
1. Run `xcodebuild build` — must compile.
2. Run `xcodebuild test` — all tests must pass.
3. Verify no `var isLoading` or `var isLoadingToolbarAction` variables remain.
4. Add unit tests: verify `isLoading(.load)` is true during async operation and false after.
