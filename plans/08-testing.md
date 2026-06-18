# Plan 08: Testing — ViewModel Unit Tests

## Goal
Add unit tests for ViewModel logic: load/success, load/error, and navigation intent for each major screen. These tests use injected mocks — no network, no simulator, run in milliseconds.

## Pre-requisite
Plans 03 (LoadingTrackable), 04 (AppAlert), 05 (fieldErrors), 06 (Destination) must be done first, because tests assert the new patterns.

## Test File Location

All new tests go in `LumberjackedTests/` target. Create one test file per ViewModel:

- `LumberjackedTests/WorkoutHistoryViewModelTests.swift`
- `LumberjackedTests/MovementCatalogViewModelTests.swift`
- `LumberjackedTests/CurrentWorkoutViewModelTests.swift`
- `LumberjackedTests/LoginViewModelTests.swift`
- `LumberjackedTests/SignupViewModelTests.swift`
- `LumberjackedTests/MovementInputViewModelTests.swift`
- `LumberjackedTests/MovementDetailViewModelTests.swift`
- `LumberjackedTests/WorkoutDetailViewModelTests.swift`
- `LumberjackedTests/MovementSelectorViewModelTests.swift`

## Standard Test Suite Per ViewModel

For each ViewModel, write three test cases:

### 1. Load populates data
```swift
func testLoadPopulatesWorkouts() async {
    let mock = MockWorkoutAPI()
    // mock returns PreviewData by default
    let vm = WorkoutHistoryView.ViewModel(workoutAPI: mock)
    await vm.attemptGetWorkouts()
    XCTAssertFalse(vm.workouts.isEmpty)
    XCTAssertFalse(vm.isLoading(.load))
}
```

### 2. Network error shows alert
```swift
func testLoadErrorShowsAlert() async {
    let mock = MockWorkoutAPI(errorToThrow: URLError(.notConnectedToInternet))
    let vm = WorkoutHistoryView.ViewModel(workoutAPI: mock)
    await vm.attemptGetWorkouts()
    XCTAssertNotNil(vm.alert)
    XCTAssertFalse(vm.isLoading(.load))
}
```

### 3. Navigation intent (for views with Destination enum)
```swift
func testWorkoutTappedSetsDestination() {
    let vm = WorkoutHistoryView.ViewModel(workoutAPI: MockWorkoutAPI())
    let workout = PreviewData.pastWorkout_today
    vm.workoutTapped(workout)
    if case .workoutDetail(let w) = vm.destination {
        XCTAssertEqual(w.id, workout.id)
    } else {
        XCTFail("Expected .workoutDetail destination")
    }
}
```

## Form ViewModel Tests (Login, Signup, MovementInput)

### Field errors from validation response
```swift
func testLoginFieldErrorsPopulated() async {
    let mock = MockAuthAPI(errorToThrow: RemoteNetworkingError(
        statusCode: 400,
        messages: ["email": ["Enter a valid email address."]]))
    let vm = LoginView.ViewModel(api: mock)
    vm.email = "notanemail"
    vm.password = "pass"
    await vm.submit()
    XCTAssertEqual(vm.fieldErrors["email"], "Enter a valid email address.")
    XCTAssertNil(vm.alert)
}
```

### Field errors cleared on retry
```swift
func testFieldErrorsClearedOnRetry() async {
    let mock = MockAuthAPI()
    let vm = LoginView.ViewModel(api: mock)
    vm.fieldErrors["email"] = "stale error"
    await vm.submit()
    XCTAssertNil(vm.fieldErrors["email"])
}
```

## Loading State Tests

```swift
func testIsLoadingDuringFetch() async {
    // Can't easily assert mid-flight with async/await unless using actors.
    // Instead assert it's false after completion:
    let vm = WorkoutHistoryView.ViewModel(workoutAPI: MockWorkoutAPI())
    await vm.attemptGetWorkouts()
    XCTAssertFalse(vm.isLoading(.load))
}
```

## Mock Updates Required

`Mocks.swift` must be updated (per Plan 07) to support `errorToThrow`:

```swift
final class MockWorkoutAPI: WorkoutAPIProtocol {
    var errorToThrow: Error?
    // init(currentWorkout:errorToThrow:) ...
    func getWorkouts() async throws -> APIResponseList<Workout> {
        if let error = errorToThrow { throw error }
        return APIResponseList(count: PreviewData.pastWorkouts.count, results: PreviewData.pastWorkouts)
    }
    // ... same pattern for all methods
}
```

## Existing Tests to Keep

- `LumberjackedClientErrorsTests.swift` — update to reflect new `fieldErrors` extraction logic (Plan 05 changes the underlying type, so these tests will need reworking).
- `LumberjackedUITests/LoginUITests.swift` — keep both test cases, verify they still pass after all refactors.

## Test Plan Verification

After all plan implementations are done:
1. `xcodebuild test -scheme Lumberjacked -destination 'platform=iOS Simulator,name=iPhone 16'` — all unit + UI tests pass.
2. Count: at minimum 3 tests per ViewModel × 9 ViewModels = 27 new tests, plus existing.
