# Plan 06: Navigation — Destination Enum

## Goal
Move navigation intent into the ViewModel via a `Destination` enum. Views react to `$viewModel.destination` rather than embedding `NavigationLink` logic inline or relying on value-typed navigation. This makes navigation testable.

## Current Navigation Patterns (to replace)

### WorkoutHistoryView.swift
Uses inline `NavigationLink(destination: WorkoutDetailView(...))` — no ViewModel involvement.

### MovementCatalogView.swift
Uses `NavigationLink(value: movement)` + `navigationDestination(for: Movement.self)` — value-based, no ViewModel.

### MovementDetailView.swift
Uses `NavigationLink()` (empty label) + `navigationDestination(for: MovementLog.self)` — value-based.

### CurrentWorkoutView.swift
Uses `navigationDestination(for: Movement.self)` and `navigationDestination(for: MovementLogDestination.self)` plus inline `NavigationLink` in the toolbar menu.

### WorkoutDetailView.swift
Uses inline `NavigationLink(destination: MovementLogInputView(...))`.

## Target Pattern

```swift
// In ViewModel:
enum Destination: Identifiable {
    case workoutDetail(Workout)
    // ...
    var id: String { ... }
}
var destination: Destination?

func workoutTapped(_ workout: Workout) {
    destination = .workoutDetail(workout)
}

// In View:
.navigationDestination(item: $viewModel.destination) { dest in
    switch dest {
    case .workoutDetail(let w): WorkoutDetailView(viewModel: .init(workout: w))
    }
}
```

## Implementation Steps Per View

### WorkoutHistoryView

1. Add `Destination` enum to `WorkoutHistoryView+ViewModel.swift`:
   ```swift
   enum Destination: Identifiable {
       case workoutDetail(Workout)
       var id: String { if case .workoutDetail(let w) = self { return "detail-\(w.id ?? 0)" }; return "" }
   }
   var destination: Destination?
   ```
2. Add intent method: `func workoutTapped(_ workout: Workout) { destination = .workoutDetail(workout) }`.
3. In view: replace `NavigationLink(destination: ...)` with `Button { viewModel.workoutTapped(workout) }`.
4. Add `.navigationDestination(item: $viewModel.destination) { ... }`.

### MovementCatalogView

1. Add `Destination` enum: `case movementDetail(Movement)`.
2. Add `func movementTapped(_ movement: Movement) { destination = .movementDetail(movement) }`.
3. Replace `NavigationLink(value: movement)` with a `Button` that calls `viewModel.movementTapped(movement)`.
4. Remove `navigationDestination(for: Movement.self)`, add `navigationDestination(item: $viewModel.destination)`.

### MovementDetailView

1. Add `Destination` enum: `case editLog(MovementLog)`.
2. Add intent method.
3. Replace `NavigationLink(value: movementLog)` with `Button`.
4. Replace `navigationDestination(for: MovementLog.self)`.

### CurrentWorkoutView

This view has two distinct nav destinations (movement detail, movement log input) plus a toolbar NavigationLink to `MovementSelectorView`. The toolbar link should become a `Button` that sets `destination = .editWorkout`.

1. Add `Destination` enum: `case movementDetail(Movement)`, `case movementLogInput(MovementLogDestination)`, `case editWorkout`.
2. Move inline NavigationLinks → buttons that set `viewModel.destination`.
3. Use single `navigationDestination(item: $viewModel.destination)`.

### WorkoutDetailView

1. Add `Destination` enum: `case movementLogInput(MovementLog, Workout)`.
2. Replace inline `NavigationLink(destination: MovementLogInputView(...))` with button.

## Note on NavigationLink(value:) vs Destination enum

The `NavigationLink(value:)` + `navigationDestination(for:)` pattern is SwiftUI-native and perfectly fine for simple cases. The key architecture requirement is that the **ViewModel drives** navigation. Both approaches satisfy this — the arch doc shows `navigationDestination(item:)` for clarity and testability. Use `navigationDestination(item: $viewModel.destination)` consistently across all views.

## Test Plan

After changes:
1. `xcodebuild build`.
2. `xcodebuild test`.
3. Unit tests: instantiate ViewModel, call intent method (e.g., `workoutTapped`), assert `destination == .workoutDetail(expectedWorkout)`.
4. Manual: navigate workout history → detail → back; navigate catalog → movement detail → back.
