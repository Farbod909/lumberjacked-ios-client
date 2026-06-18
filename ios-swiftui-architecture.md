# iOS SwiftUI Architecture Guide

Derived from comparing Lumberjacked (hand-written, production) and Nursebot (AI-assisted) iOS clients.
Minimum deployment target: **iOS 17**.

---

## SwiftUI Concepts Glossary

These decorators come up constantly. Keep this as a reference.

| Decorator | What it does | When to use |
|---|---|---|
| `@Observable` | Marks a class so SwiftUI auto-tracks all its properties. No `@Published` needed. | All ViewModels (iOS 17+) |
| `@MainActor` | Ensures all code in the class runs on the main thread. Required for UI updates. | All ViewModels |
| `@State` | View owns the value. Survives re-renders. Use for `@Observable` ViewModels and simple local UI state. | `@State var viewModel = ViewModel()` |
| `@Binding` | Two-way connection to a `@State` owned by a parent. Changes flow both ways. | Child views that need to mutate parent state |
| `@EnvironmentObject` | Injects a value from an ancestor view into any descendant, invisibly. | Auth routing only — never in ViewModels |
| `ViewModifier` | A reusable transformation you apply to any view with `.modifier()` or a custom extension. | Shared UI patterns like field errors, loading overlays |
| `@StateObject` | (iOS 14 legacy) Like `@State` but for `ObservableObject` classes. Avoid in new code — use `@State` with `@Observable` instead. | Only when targeting iOS 14/15/16 |

---

## Project Structure

Feature-based. Everything related to a screen lives in one folder.

```
MyApp/
├── Features/
│   ├── WorkoutList/
│   │   ├── WorkoutListView.swift
│   │   └── WorkoutListView+ViewModel.swift
│   ├── WorkoutDetail/
│   │   ├── WorkoutDetailView.swift
│   │   └── WorkoutDetailView+ViewModel.swift
│   └── Auth/
│       ├── LoginView.swift
│       └── LoginView+ViewModel.swift
├── Models/
│   └── Workout.swift
├── Services/
│   ├── APIClient.swift
│   ├── APIClient+Workouts.swift    ← endpoints grouped by resource
│   ├── AuthService.swift
│   └── KeychainService.swift
├── Utilities/
│   ├── AppAlert.swift
│   ├── LoadingTrackable.swift
│   ├── LoadingButton.swift
│   └── FieldErrorModifier.swift
└── Root/
    └── RootView.swift
```

---

## ViewModel Pattern

### Rule
Every screen has a paired ViewModel file. The ViewModel is a Swift extension on the View — this namespaces it without coupling it to the view's file.

### File naming
`WorkoutListView+ViewModel.swift` — the `+` signals it is an extension, matching Swift ecosystem conventions.

### Template

```swift
// WorkoutListView.swift
struct WorkoutListView: View {
    @State var viewModel = ViewModel()   // short — unambiguous inside this view

    var body: some View {
        List(viewModel.workouts) { workout in
            Button(workout.name) {
                viewModel.workoutTapped(workout)
            }
        }
        .task { await viewModel.load() }
        .alert(item: $viewModel.alert)
        .navigationDestination(item: $viewModel.destination) { dest in
            switch dest {
            case .detail(let workout): WorkoutDetailView(workout: workout)
            case .createNew: CreateWorkoutView()
            }
        }
    }
}
```

```swift
// WorkoutListView+ViewModel.swift
extension WorkoutListView {

    @MainActor          // all property updates run on main thread automatically
    @Observable         // SwiftUI tracks every property — no @Published needed
    final class ViewModel: LoadingTrackable {

        // MARK: - State
        var workouts: [Workout] = []
        var alert: AppAlert?
        var destination: Destination?
        var loadingKeys: Set<LoadingKey> = []   // required by LoadingTrackable

        // MARK: - Dependencies
        private let api: WorkoutAPIProtocol

        init(api: WorkoutAPIProtocol = APIClient.shared) {
            self.api = api
        }

        // MARK: - Loading Keys
        enum LoadingKey { case load, save, delete }

        // MARK: - Navigation
        enum Destination: Identifiable {
            case detail(Workout)
            case createNew

            var id: String {
                switch self {
                case .detail(let w): return "detail-\(w.id)"
                case .createNew: return "createNew"
                }
            }
        }

        // MARK: - Intent
        func load() async {
            try? await withLoading(.load) {
                workouts = try await api.getWorkouts()
            }
        }

        func workoutTapped(_ workout: Workout) {
            destination = .detail(workout)
        }
    }
}
```

### Why the extension pattern
- From outside the view: `WorkoutListView.ViewModel` — fully qualified and unambiguous.
- Inside the view: just `ViewModel()` — no repetition.
- The `+ViewModel` filename makes the relationship obvious in Xcode's file tree.

---

## Loading State

### Rule
All ViewModels adopt `LoadingTrackable`. Loading is tracked per-action using a typed enum, not a single boolean. This lets individual buttons show spinners independently.

### Define once in Utilities

```swift
// LoadingTrackable.swift
protocol LoadingTrackable: AnyObject {
    associatedtype LoadingKey: Hashable
    var loadingKeys: Set<LoadingKey> { get set }
}

extension LoadingTrackable {
    func isLoading(_ key: LoadingKey) -> Bool {
        loadingKeys.contains(key)
    }

    // Wraps async work: sets the key before, removes it after — even if the action throws.
    // `defer` is Swift's "run this no matter what happens" — guarantees cleanup on error.
    func withLoading(_ key: LoadingKey, action: () async throws -> Void) async throws {
        loadingKeys.insert(key)
        defer { loadingKeys.remove(key) }
        try await action()
    }
}
```

### LoadingButton

Replaces the label with a spinner while loading. The label stays invisible (not removed) so the button doesn't resize.

```swift
// LoadingButton.swift
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

### Usage

```swift
LoadingButton(label: "Save", isLoading: viewModel.isLoading(.save)) {
    await viewModel.save()
}

LoadingButton(label: "Delete", isLoading: viewModel.isLoading(.delete)) {
    await viewModel.delete()
}
```

---

## Alerts

### Rule
All alerts are driven by a single optional `AppAlert` on the ViewModel. Set it to show an alert; set it to `nil` to dismiss. Supports dismiss-only and confirm/cancel variants.

### Define once in Utilities

```swift
// AppAlert.swift
struct AppAlert: Identifiable {
    let id = UUID()
    var title: String
    var message: String? = nil
    var confirmAction: (() -> Void)? = nil   // nil = dismiss-only, set = confirm/cancel
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

### Usage

```swift
// Info alert
alert = AppAlert(title: "Saved", message: "Your workout was saved.")

// Confirm/cancel
alert = AppAlert(
    title: "Delete workout?",
    message: "This cannot be undone.",
    confirmAction: { Task { await self.deleteWorkout() } },
    confirmLabel: "Delete",
    cancelLabel: "Cancel"
)
```

```swift
// In the view — one line
.alert(item: $viewModel.alert)
```

---

## Error Handling

### Two cases

**General errors** (network failures, server errors) → surface as an `AppAlert` on the ViewModel.

**Field errors** (form validation) → a `[String: String]` dictionary keyed by field name. Reset the whole dictionary at the top of each submission attempt.

### Form ViewModel pattern

```swift
@MainActor
@Observable
final class LoginViewModel: LoadingTrackable {
    var email = ""
    var password = ""
    var fieldErrors: [String: String] = [:]
    var alert: AppAlert?
    var loadingKeys: Set<LoadingKey> = []

    enum LoadingKey { case submit }

    func submit() async {
        fieldErrors = [:]   // reset all field errors on each attempt

        try? await withLoading(.submit) {
            do {
                try await AuthService.login(email: email, password: password)
            } catch let e as ValidationError {
                fieldErrors = e.fieldErrors   // e.g. ["email": "Already in use"]
            } catch {
                alert = AppAlert(title: "Login failed", message: error.localizedDescription)
            }
        }
    }
}
```

### FieldError ViewModifier

Automatically shows/hides a red error label and border. Defined once, applied with one line per field.

```swift
// FieldErrorModifier.swift
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

### Usage

```swift
TextField("Email", text: $viewModel.email)
    .fieldError(viewModel.fieldErrors["email"])

SecureField("Password", text: $viewModel.password)
    .fieldError(viewModel.fieldErrors["password"])
```

---

## Navigation

### Rule
The ViewModel owns navigation intent via a `Destination` enum. The view observes it and renders the correct destination. This makes navigation testable — you assert the ViewModel's `destination` property rather than simulating taps.

### Pattern (shown in ViewModel template above)

```swift
// ViewModel sets destination
func workoutTapped(_ workout: Workout) {
    destination = .detail(workout)
}

// View reacts
.navigationDestination(item: $viewModel.destination) { dest in
    switch dest {
    case .detail(let workout): WorkoutDetailView(workout: workout)
    case .createNew: CreateWorkoutView()
    }
}
```

### Data flow between screens

Pass the full object from parent to detail. The detail ViewModel displays it immediately and can refresh on demand — no unnecessary network round-trips on navigation.

```swift
// WorkoutDetailView+ViewModel.swift
extension WorkoutDetailView {
    @MainActor
    @Observable
    final class ViewModel: LoadingTrackable {
        var workout: Workout          // shown immediately from what parent passed
        var loadingKeys: Set<LoadingKey> = []
        private let api: WorkoutAPIProtocol

        enum LoadingKey { case refresh }

        init(workout: Workout, api: WorkoutAPIProtocol = APIClient.shared) {
            self.workout = workout
            self.api = api
        }

        func refresh() async {
            try? await withLoading(.refresh) {
                workout = try await api.getWorkout(id: workout.id)
            }
        }
    }
}
```

---

## Auth State

### Rule
Auth state lives in a single `AuthViewModel` injected at the root via `@EnvironmentObject`. It is **only** used for routing (show login or main app). ViewModels never depend on it — the `APIClient` handles the token silently via Keychain.

```swift
// RootView.swift
struct RootView: View {
    @EnvironmentObject var auth: AuthViewModel

    var body: some View {
        if auth.isCheckingToken {
            ProgressView()
        } else if auth.isAuthenticated {
            MainTabView()
        } else {
            LoginView()
        }
    }
}

// MyApp.swift
@main
struct MyApp: App {
    @State var auth = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(auth)
        }
    }
}
```

Handle session expiration (401 responses) by posting a notification from `APIClient` and observing it in `AuthViewModel`:

```swift
// In APIClient when a 401 is received:
NotificationCenter.default.post(name: .appUnauthorized, object: nil)

// In AuthViewModel:
init() {
    NotificationCenter.default.addObserver(
        forName: .appUnauthorized, object: nil, queue: .main
    ) { [weak self] _ in
        self?.isAuthenticated = false
    }
}
```

---

## Networking / Services

### Layers

```
APIClient          ← raw HTTP, token attachment, error mapping
  ↓
Resource extensions ← one extension file per resource area
  ↓
AuthService        ← combines APIClient + KeychainService for auth flows
  ↓
ViewModel          ← calls the resource method it needs, nothing lower
```

### APIClient

```swift
// APIClient.swift
actor APIClient {                    // `actor` = thread-safe singleton automatically
    static let shared = APIClient()

    private let baseURL = "https://api.myapp.com"

    enum APIError: Error, LocalizedError {
        case unauthorized
        case serverError(Int)
        case decodingError(Error)
        case networkError(Error)
    }
}
```

```swift
// APIClient+Workouts.swift
extension APIClient: WorkoutAPIProtocol {
    func getWorkouts() async throws -> [Workout] {
        try await get("/workouts")
    }

    func getWorkout(id: Int) async throws -> Workout {
        try await get("/workouts/\(id)")
    }

    func saveWorkout(_ workout: Workout) async throws -> Workout {
        try await post("/workouts", body: workout)
    }
}
```

### Protocols — one per resource area

```swift
// Define in the same file as the extension, or alongside the feature
protocol WorkoutAPIProtocol {
    func getWorkouts() async throws -> [Workout]
    func getWorkout(id: Int) async throws -> Workout
    func saveWorkout(_ workout: Workout) async throws -> Workout
}
```

ViewModel `init` takes the protocol with the real client as default:

```swift
init(api: WorkoutAPIProtocol = APIClient.shared) {
    self.api = api
}
```

---

## Testing

### Unit tests — ViewModel logic

Inject a mock that conforms to the resource protocol. No network, no simulator, runs in milliseconds.

```swift
// In main target, stripped from release builds
#if DEBUG
final class MockWorkoutAPI: WorkoutAPIProtocol {
    var workoutsToReturn: [Workout] = []
    var errorToThrow: Error? = nil

    func getWorkouts() async throws -> [Workout] {
        if let error = errorToThrow { throw error }
        return workoutsToReturn
    }

    func getWorkout(id: Int) async throws -> Workout { workoutsToReturn[0] }
    func saveWorkout(_ workout: Workout) async throws -> Workout { workout }
}
#endif
```

```swift
// WorkoutListViewModelTests.swift
func testLoadPopulatesWorkouts() async {
    let mock = MockWorkoutAPI()
    mock.workoutsToReturn = [Workout(name: "Deadlift")]
    let vm = WorkoutListView.ViewModel(api: mock)

    await vm.load()

    XCTAssertEqual(vm.workouts.count, 1)
    XCTAssertEqual(vm.workouts[0].name, "Deadlift")
    XCTAssertFalse(vm.isLoading(.load))
}

func testLoadErrorShowsAlert() async {
    let mock = MockWorkoutAPI()
    mock.errorToThrow = URLError(.notConnectedToInternet)
    let vm = WorkoutListView.ViewModel(api: mock)

    await vm.load()

    XCTAssertNotNil(vm.alert)
}

func testNavigationOnTap() {
    let vm = WorkoutListView.ViewModel(api: MockWorkoutAPI())
    let workout = Workout(name: "Squat")

    vm.workoutTapped(workout)

    if case .detail(let w) = vm.destination {
        XCTAssertEqual(w.name, "Squat")
    } else {
        XCTFail("Expected .detail destination")
    }
}
```

### UI tests — critical paths only

Use `XCUITest` for the flows that must never break (login, core happy path). Keep these minimal — they are slow and brittle.

```swift
func testLoginFlow() {
    let app = XCUIApplication()
    app.launch()

    app.textFields["Email"].tap()
    app.textFields["Email"].typeText("user@example.com")
    app.secureTextFields["Password"].typeText("secret")
    app.buttons["Login"].tap()

    XCTAssert(app.staticTexts["Welcome"].waitForExistence(timeout: 5))
}
```

### SwiftUI Previews

The same `#if DEBUG` mock used in tests powers previews — one definition, two uses.

```swift
#Preview {
    NavigationStack {
        WorkoutListView(viewModel: {
            let vm = WorkoutListView.ViewModel(api: MockWorkoutAPI())
            vm.workouts = [Workout(name: "Deadlift"), Workout(name: "Squat")]
            return vm
        }())
    }
}
```

---

## Quick-Reference Checklist

For each new screen:

- [ ] Create `FeatureNameView.swift` and `FeatureNameView+ViewModel.swift` in `Features/FeatureName/`
- [ ] Mark ViewModel `@MainActor` and `@Observable`
- [ ] Adopt `LoadingTrackable`, define `LoadingKey` enum
- [ ] Define `Destination` enum if the screen navigates anywhere
- [ ] Add `var alert: AppAlert?` for errors and confirmations
- [ ] Add `var fieldErrors: [String: String] = [:]` if the screen has a form
- [ ] Clear `fieldErrors` at the top of each submit function
- [ ] Inject API dependency via protocol, with `APIClient.shared` as default
- [ ] Add `MockFeatureAPI` under `#if DEBUG` for tests and previews
- [ ] Write unit tests for: load, error state, navigation intent
