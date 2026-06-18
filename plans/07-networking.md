# Plan 07: Networking / Services — Assessment and Minor Alignment

## Goal
Assess the current networking layer against the architecture doc and make targeted improvements. The major DI refactor (protocols per resource) was done in a prior session. This plan addresses remaining gaps.

## Current State

### What's already aligned
- `WorkoutAPIProtocol`, `MovementAPIProtocol`, `MovementLogAPIProtocol`, `AuthAPIProtocol` all exist in `APIProtocols.swift`.
- `LiveWorkoutAPI`, `LiveMovementAPI`, `LiveMovementLogAPI`, `LiveAuthAPI` implement these.
- ViewModels inject via `init(api: XxxAPIProtocol = LiveXxxAPI())`.
- `#if DEBUG` mocks exist in `Mocks.swift`.

### Gaps vs architecture doc

1. **No central `APIClient` actor** — instead each `Live*API` directly calls `Networking.shared.request(options:)`. The arch doc calls for a single `APIClient` actor as the HTTP layer. This is cosmetic for testability (protocols already abstract it), but the layering is off.

2. **`LumberjackedClient.swift` has dead weight** — it contains `LumberjackedClientErrors` (to be deleted in Plan 05) plus several `LumberjackedClientActionRequest` helper structs that wrap ViewModel async operations. These request structs are architectural leftovers and should be removed as ViewModels are refactored in Plans 03-05.

3. **`Networking.swift` base URL** — already swappable via a config; confirm it reads from a build config plist or environment variable rather than being hardcoded.

4. **Protocol file organization** — arch doc recommends protocols live alongside their resource extension (e.g., `APIClient+Workouts.swift`). Currently all protocols are in one `APIProtocols.swift`. This is fine for now given the project size — no change required.

## Implementation Steps

### Step 1: Clean up LumberjackedClient.swift

After Plans 04 and 05 remove all usages of `LumberjackedClientErrors` and the request helper structs:
- Delete `LumberjackedClientErrors` struct.
- Delete any `LumberjackedClientActionRequest` structs that are no longer referenced.
- If the file becomes empty, delete it.

### Step 2: Verify base URL configurability

Check `Networking.swift` — confirm `baseURL` is not hardcoded as a string literal in the source. If it is, extract to a build-setting-backed `Info.plist` entry or `ProcessInfo.processInfo.environment["API_BASE_URL"]` fallback.

Current observation: the staging server is `localhost:8000`. Confirm there is a mechanism to switch to production without a code change (e.g., different scheme → different Info.plist value).

### Step 3: Mock configurability

The arch doc shows mocks with configurable return values:
```swift
final class MockWorkoutAPI: WorkoutAPIProtocol {
    var workoutsToReturn: [Workout] = []
    var errorToThrow: Error? = nil
    func getWorkouts() async throws -> [Workout] {
        if let error = errorToThrow { throw error }
        return workoutsToReturn
    }
}
```

Current mocks return hardcoded `PreviewData`. Update mocks to expose `var errorToThrow: Error?` on each mock so unit tests can inject errors without subclassing.

Files: `Mocks.swift` — add `errorToThrow` property to `MockWorkoutAPI`, `MockMovementAPI`, `MockMovementLogAPI`, `MockAuthAPI`.

## Test Plan

After changes:
1. `xcodebuild build`.
2. `xcodebuild test` — all existing tests pass.
3. Verify `MockWorkoutAPI(errorToThrow: URLError(.notConnectedToInternet))` can be created and used in a test.
4. Confirm no `localhost:8000` is hardcoded in any source file (should be in a config file only).
