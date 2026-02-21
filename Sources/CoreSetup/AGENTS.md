# iOS App — Agent Instructions Template

> **Usage:** Copy this file into a new iOS project and customize project-specific sections (marked with `TODO`). It provides standard patterns for SwiftUI apps using modern Swift concurrency so the LLM already knows how to build common features.

---

## 1. Architecture (MVVM + @Observable)

This app follows **MVVM** with four layers:

| Layer | Responsibility | Owns business logic? |
|---|---|---|
| **Model** | Domain data, validation, computed properties | Yes |
| **Service** | Backend API calls, SDK wrappers | No |
| **Repository** | Shared state, caching, persistence | No (stores only) |
| **ViewModel** | Orchestrates services/repos, exposes state to views | No (delegates to models) |

### Rules
- ViewModels use `@Observable` + `@MainActor`. Views own them via `@State`.
- Never nest a ViewModel inside another ViewModel.
- Services are `final class` + `Sendable`. They return domain models, not raw API types.
- Models are structs, conforming to `Sendable` and `Hashable` where needed.
- Business logic lives in models, not ViewModels or services.

### ViewModel Template
```swift
@MainActor
@Observable
final class SomeFeatureViewModel {
    // MARK: - State
    var items: [SomeItem] = []
    var loading = true

    // MARK: - Dependencies
    private let someService = SomeService()
    let someRepository: SomeRepository = DependencyContainer.resolve()

    // MARK: - Intents
    func fetchItems() async throws {
        defer { loading = false }
        items = try await someService.fetchItems()
    }
}
```

### View Template
```swift
struct SomeFeatureView: View {
    @State private var viewModel = SomeFeatureViewModel()

    var body: some View {
        // UI here
        .task { try? await viewModel.fetchItems() }
    }
}
```

---

## 2. App Launch & Welcome Screen

The app's root view (`WelcomeView` or equivalent) handles three concerns in order:

### Launch Sequence
1. **Show loading state** (splash/blank screen) while SDKs initialize.
2. **Initialize SDKs** sequentially in `onFirstAppear` / `.task {}`:
   - Analytics SDK (skip for TestFlight/debug if needed)
   - Register analytics in DI container
   - Subscription SDK (Adapty, RevenueCat, etc.)
   - Fetch current subscription status
3. **Authenticate** — call the auth service (e.g., `authService.signInIfNeeded()`).
4. **Route** based on profile state:

```swift
enum WelcomeScreenState {
    case loading    // SDKs initializing
    case onboarding // Profile incomplete
    case home       // Main app screen
}
```

### Rules
- SDK init must complete before auth; auth must complete before routing.
- If auth fails, default to `.onboarding` (not a crash).
- Keep the loading state visually clean (background color/gradient, no spinner unless > 1s).

### Template
```swift
@MainActor
@Observable
final class WelcomeViewModel {
    var state: WelcomeScreenState = .loading

    private let authService = AuthService()
    private let analyticsService = AnalyticsService()
    private let subscriptionService = SubscriptionService()

    func initialize() async {
        // 1. Analytics
        await analyticsService.setup()

        // 2. Subscriptions
        await subscriptionService.setup()
        await subscriptionService.fetchStatus()

        // 3. Auth + routing
        do {
            let profile = try await authService.signInIfNeeded()
            state = profile.isFulfilled ? .home : .onboarding
        } catch {
            state = .onboarding
        }
    }
}
```

---

## 3. Onboarding (onboarding-ios library)

Onboarding is built with the [`onboarding-ios`](https://github.com/VPavelDm/Onboarding-iOS) SPM package. The flow is **JSON-driven**: steps are defined in a JSON file, the library renders built-in UI for standard step types, and the app provides custom SwiftUI views for app-specific steps.

### SPM Dependency
```swift
.package(url: "https://github.com/VPavelDm/Onboarding-iOS", from: "<version>")
```
The package provides these libraries: `Onboarding`, `CoreUI`, `CoreAnalytics`, `CoreStorage`, `CoreNetwork`, `Paywalls`, `Profile`, `GPTApi`.

### Folder Structure
```
Onboarding/
├── View/
│   ├── OnboardingView.swift              # Entry point — configures OnboardingView from the library
│   ├── SomeCustomStepView.swift          # Custom step views (one per custom step)
│   └── ...
├── ViewModel/
│   ├── OnboardingViewModel.swift         # State, dependencies, business logic
│   └── OnboardingViewModel+Delegate.swift # OnboardingDelegate implementation
└── Model/
    ├── Base.lproj/onboarding_steps.json  # Step definitions (base language)
    ├── <lang>.lproj/onboarding_steps.json # Localized step definitions (optional)
    ├── <lang>.lproj/Onboarding.strings   # Localized strings for custom views
    ├── AppColorPalette.swift             # ColorPalette implementation
    └── Bundle+onboardingSteps.swift      # Localized JSON URL helper
```

### Key Library Types

| Type | Role |
|---|---|
| `OnboardingView` | SwiftUI view that renders the onboarding flow |
| `OnboardingConfiguration` | Config: JSON URL, bundle, localization table name |
| `OnboardingDelegate` | Protocol — called when user answers a step |
| `ColorPalette` | Protocol — theme colors for the onboarding UI |
| `CustomStepParams` | Passed to your custom step view builder; call `await params()` to advance |
| `UserAnswer` | Contains `onboardingStepID: StepID` and `payloads: [Payload]` |
| `StepID` | Typealias for `String` — matches the `"id"` field in JSON |

### Entry Point View
```swift
struct OnboardingInitialView: View {
    @State private var viewModel = OnboardingViewModel()

    var body: some View {
        OnboardingView(
            configuration: OnboardingConfiguration(
                url: Bundle.main.onboardingStepsURL,
                bundle: .main,
                tableName: "Onboarding"
            ),
            delegate: viewModel,
            colorPalette: AppColorPalette(),
            customStepView: customStepView(params:)
        )
    }

    @ViewBuilder
    private func customStepView(params: CustomStepParams) -> some View {
        switch params.currentStepID {
        case "some_custom_step":
            SomeCustomStepView { await params() }
        case "paywall":
            PaywallHostView(placementID: "onboarding", close: { await params() })
        default:
            EmptyView()
        }
    }
}
```

### OnboardingDelegate Implementation
```swift
extension OnboardingViewModel: OnboardingDelegate {
    func onAnswer(userAnswer: UserAnswer, allAnswers: [UserAnswer]) async {
        switch userAnswer.onboardingStepID {
        case "enter_name":
            let name = userAnswer.payloads.first?.string ?? ""
            try? await profileService.updateName(name)
        case "select_goal":
            let goal = userAnswer.payloads.first?.string ?? ""
            try? await preferencesService.savePreference(key: "goal", value: goal)
        default:
            break
        }
    }

    func format(string: String) -> String {
        // Replace placeholders like "{name}" with actual values
        string.replacingOccurrences(of: "{name}", with: name)
    }
}
```

### ColorPalette Implementation
```swift
struct AppColorPalette: ColorPalette {
    var textColor: Color = .primary
    var secondaryTextColor: Color = .secondary
    var primaryButtonForegroundColor: Color = .primary
    var primaryButtonBackground: AnyShapeStyle = AnyShapeStyle(Color.accentColor)
    var secondaryButtonForegroundColor: Color = .white
    var secondaryButtonBackground: AnyShapeStyle = AnyShapeStyle(Color.accentColor.opacity(0.2))
    var secondaryButtonStrokeColor: Color = .accentColor.opacity(0.2)
    var plainButtonColor: Color = .white
    var progressBarBackgroundColor: AnyShapeStyle = AnyShapeStyle(Color.accentColor.opacity(0.2))
    var orbitColor: Color = Color(uiColor: .systemGray6)
    var accentColor: Color = .accentColor
}
```

### JSON Step Definition Format

Steps are defined in `onboarding_steps.json`. Each step has `id`, `type`, and `payload`:

```json
[
    {
        "id": "feature_showcase",
        "type": "featureShowcase",
        "payload": {
            "title": "Track smarter with AI",
            "description": "Optional description",
            "image": { "type": "named", "value": "showcase", "aspectRatioType": "fit" },
            "backgroundColor": "1A1A1A",
            "answer": { "title": "Continue", "nextStepID": "next_step_id" }
        }
    },
    {
        "id": "notification_permission",
        "type": "custom",
        "payload": { "nextStepID": "next_step_id" }
    }
]
```

### Available Step Types

| Type | JSON `type` value | Description |
|---|---|---|
| Feature showcase | `featureShowcase` | Full-screen image with title, description, CTA button |
| Single answer | `oneAnswer` | Radio-button style single selection |
| Multiple answer | `multipleAnswer` | Checkbox style multi-selection |
| Binary answer | `binaryAnswer` | Two-option choice (yes/no style) |
| Description | `description` | Informational screen with optional image |
| Welcome | `welcome` | Welcome screen with animated emojis |
| Welcome fade | `welcomeFade` | Sequential fade-in messages |
| Enter value | `enterValue` | Text input field |
| Age picker | `agePicker` | Age selection wheel |
| Height picker | `heightPicker` | Height with metric/imperial toggle |
| Weight picker | `weightPicker` | Weight with metric/imperial toggle |
| Time picker | `timePicker` | Time selection |
| Progress | `progress` | Animated progress bar with step labels |
| Social proof | `socialProof` | User review, stats, testimonials |
| Discount wheel | `discountWheel` | Spin-to-win gamified discount |
| Widget | `widget` | Informational card with image |
| Custom | `custom` | App provides its own SwiftUI view |

### Answer Payloads
Each answer in JSON can carry a payload:
```json
{
    "title": "Male",
    "nextStepID": "enter_age",
    "payload": { "type": "string", "value": "male" }
}
```
Access in delegate: `userAnswer.payloads.first?.string` for strings, `.data` for JSON.

### Localized JSON Loading Helper
```swift
extension Bundle {
    var onboardingStepsURL: URL {
        let langCode = Locale.current.language.languageCode?.identifier ?? "en"
        if let url = Bundle.main.url(forResource: "onboarding_steps", withExtension: "json",
                                      subdirectory: nil, localization: langCode) {
            return url
        }
        return Bundle.main.url(forResource: "onboarding_steps", withExtension: "json")!
    }
}
```

### Rules
- **JSON-driven**: Define the step sequence and content in `onboarding_steps.json`, not in code.
- **Custom steps** for app-specific UI: implement as separate SwiftUI views, switch on `params.currentStepID`, call `await params()` to advance.
- **Delegate handles side effects**: profile updates, preference saves, analytics — all in `onAnswer`.
- **`format(string:)`** for dynamic text: replace placeholders like `{name}` in step titles/descriptions.
- Request permissions (notifications, health, etc.) as `custom` steps — never bundle multiple permissions.
- On completion, update the profile so `WelcomeView` routes to the home screen.
- Localize by providing per-language `onboarding_steps.json` files in `.lproj` folders and an `Onboarding.strings` table.

---

## 4. Authentication

### Patterns

| Pattern | When to use |
|---|---|
| **Anonymous auth** | Zero-friction onboarding; user gets an account silently |
| **Social sign-in** | Apple, Google; always offer Apple on iOS |
| **Email/password** | Traditional; always pair with email verification |

### Rules
- Auth is handled by a single `AuthService` that wraps the backend SDK.
- On app launch, attempt silent session restore before showing login UI.
- Store tokens via the backend SDK's built-in persistence (Keychain-backed).
- Never store auth tokens in UserDefaults.
- Profile sync: after auth, fetch or create the user profile in the backend.
- Handle token refresh transparently — the service layer should retry on 401.

### Template
```swift
final class AuthService: Sendable {
    func signInIfNeeded() async throws -> UserProfile {
        // Attempt session restore
        if let session = try? await client.auth.session {
            return try await fetchProfile(userId: session.user.id)
        }
        // Fall back to anonymous sign-in
        let session = try await client.auth.signInAnonymously()
        return try await fetchOrCreateProfile(userId: session.user.id)
    }
}
```

---

## 5. Navigation

### Patterns
- **Root routing**: The Welcome/root view switches between loading, onboarding, and home.
- **Sheet presentation**: Use `.sheet(item:)` with optional `@State` properties for modal screens.
- **NavigationStack**: Use for hierarchical flows (settings, detail screens).
- **Routing enums**: For complex navigation, use an enum to represent destinations.

### Rules
- Prefer sheets over full-screen covers unless the design requires it.
- Use `@State` properties (optional or boolean) to drive navigation — not imperative `present()`.
- Dismiss via `@Environment(\.dismiss)`.

### Template
```swift
struct HomeView: View {
    @State private var selectedItem: SomeItem?
    @State private var showingSettings = false

    var body: some View {
        NavigationStack {
            ContentView()
                .sheet(item: $selectedItem) { item in
                    DetailView(item: item)
                }
                .sheet(isPresented: $showingSettings) {
                    SettingsView()
                }
        }
    }
}
```

---

## 6. Service Layer

Services are thin async wrappers around backend APIs. They translate raw API responses into domain models.

### Rules
- One service per domain (e.g., `ProfileService`, `RecordsService`).
- Services are `final class` + `Sendable`.
- All methods are `async throws`.
- Return domain models — convert from API response types via `init(apiModel:)`.
- No business logic, no state, no caching.
- Name files `SomeNameService.swift` (add backend suffix if needed, e.g., `SomeNameSBService.swift`).

### Template
```swift
final class SomeItemService: Sendable {
    private let client = APIClient.shared

    func fetchItems() async throws -> [SomeItem] {
        let response: [APIItemResponse] = try await client
            .from("items")
            .select()
            .execute()
            .value
        return response.map { SomeItem(apiModel: $0) }
    }

    func deleteItem(id: UUID) async throws {
        try await client
            .from("items")
            .delete()
            .eq("id", value: id)
            .execute()
    }
}
```

---

## 7. Repositories & Dependency Injection

Repositories store shared state (subscription status, user preferences, cached data). They are singletons managed by a DI container.

### Registration
```swift
struct DependencyRegistration {
    @MainActor
    static func registerDependencies() {
        DependencyContainer.registerSingleton(
            SomeRepository(),
            for: SomeRepository.self
        )
    }
}
```

### Resolution (in ViewModels)
```swift
let someRepository: SomeRepository = DependencyContainer.resolve()
```

### Rules
- Register all singletons at app launch, before any view appears.
- Repositories own state; ViewModels read/write through them.
- Use UserDefaults for persistence that must survive app restarts.
- Use in-memory storage for session-scoped data.
- Keep repositories focused — one per domain concern.

---

## 8. Subscriptions & Paywall

### Setup Sequence (part of app launch)
1. Configure the subscription SDK (Adapty, RevenueCat, etc.) with the API key.
2. Fetch the current subscription status.
3. Cache status in a `SubscriptionRepository` singleton.

### Paywall Presentation
- Check `subscriptionRepository.isSubscribed` before gating features.
- Present paywall as a `.sheet`.
- After purchase, refresh status in the repository.

### Rules
- Never hard-code product IDs — fetch from the SDK's configured offerings.
- Handle restore purchases.
- Degrade gracefully if the subscription SDK is unreachable (assume free tier).
- Log paywall views and purchase events to analytics.

### Template
```swift
@MainActor
@Observable
final class SubscriptionRepository {
    var isSubscribed = false

    private let subscriptionService = SubscriptionService()

    func fetchStatus() async {
        isSubscribed = (try? await subscriptionService.checkAccess()) ?? false
    }
}
```

---

## 9. Analytics

### Architecture
Use a protocol to abstract the analytics provider so the app is not coupled to a specific SDK.

```swift
protocol AnalyticsProvider {
    func track(event: String, properties: [String: Any])
    func identify(userId: String)
}
```

### Rules
- Initialize analytics early in the launch sequence, before auth.
- Skip analytics initialization for TestFlight/debug builds if the provider charges per event.
- Track meaningful events: screen views, key actions, errors — not every tap.
- Use typed event factories (enums or static methods) instead of raw strings scattered in code.
- Register the analytics provider in the DI container.

### Template
```swift
enum AnalyticsEvent {
    case screenViewed(name: String)
    case featureUsed(name: String)
    case purchaseCompleted(productId: String)
    case error(domain: String, message: String)

    var name: String { /* switch on self */ }
    var properties: [String: Any] { /* switch on self */ }
}
```

---

## 10. Push Notifications

### Flow
1. **Request permission** during onboarding — implement as a `custom` step in `onboarding_steps.json` with a dedicated `NotificationPermissionView`.
2. **Register** for remote notifications in `AppDelegate`.
3. **Send device token** to backend after auth.
4. **Handle** incoming notifications (foreground, background, launch).

### Rules
- Request permission as a dedicated onboarding `custom` step — never silently on first launch.
- Handle the case where the user denies permission gracefully (don't re-ask immediately).
- Use `UNUserNotificationCenter` delegate for foreground handling.
- Parse notification payloads into typed models before routing.

---

## 11. Error Handling

### Strategy

| Context | Approach |
|---|---|
| **Data fetch on screen load** | Show inline error / retry button |
| **Background refresh** | Fail silently, log to analytics |
| **User-initiated action** | Show alert with localized message |
| **Auth failure** | Redirect to sign-in / onboarding |

### Rules
- Never show raw error messages to users — map to localized, user-friendly text.
- Log all errors to analytics with domain + message.
- Use `defer { loading = false }` in ViewModels so loading state clears even on error.
- For retryable operations, provide a retry closure or button.
- Use a shared alert modifier (e.g., `GenericErrorAlert`) to present errors consistently.

### Template
```swift
@MainActor
@Observable
final class SomeViewModel {
    var error: Error?

    func doSomething() async {
        do {
            try await service.action()
        } catch {
            self.error = error
            AnalyticsProvider.track(.error(domain: "SomeFeature", message: error.localizedDescription))
        }
    }
}
```

---

## 12. Localization

### Format
- Use Apple's `.xcstrings` format (Xcode 15+).
- Localization file lives in `Supporting Files/Localizable.xcstrings`.

### Rules
- **All** user-facing strings must be localized — no hardcoded strings in views.
- Use `LocalizedStringResource` for programmatic access and `LocalizedStringKey` for SwiftUI `Text`.
- Use string interpolation in localized strings for dynamic values: `"Hello, \(name)"`.
- TODO: List supported languages here (e.g., English, Spanish, German).

---

## 13. UI Patterns

### Design System (CoreUI)
Maintain a shared `CoreUI` module/folder with reusable components:
- **Button styles**: `PrimaryButtonStyle`, `SecondaryButtonStyle`
- **Text field styles**: `PrimaryTextFieldStyle`
- **View modifiers**: Loading overlay (`ActivityIndicatorModifier`), pressable effect, async change handler
- **Alerts**: Shared error alert modifier
- **Buttons**: `CloseButton` for dismiss actions

### Rules
- Always reuse existing CoreUI components before creating new ones.
- Keep view `body` concise — extract subviews and use `// MARK: -` sections.
- Split complex views into extensions in separate files: `SomeView+Toolbar.swift`, `SomeView+Sheets.swift`.
- Use `@FocusState` for keyboard management.
- Use `.task {}` (or a custom `onFirstAppear` modifier) for initial data loading — never `onAppear` with a flag.

### Loading States
```swift
// In ViewModel
var loading = true

func fetch() async throws {
    defer { loading = false }
    items = try await service.fetchItems()
}

// In View
.overlay {
    if viewModel.loading {
        ProgressView()
    }
}
```

---

## 14. Testing

### Framework
- Use **Swift Testing** (`import Testing`), not XCTest.
- Use `@Test` for test functions and `#expect` for assertions.

### Rules
- Write tests that cover behavior, not implementation details.
- When fixing tests, update the test — do not delete it.
- Prefer fakes (hand-written) over mocks (generated).
- Test models and business logic in isolation — they should have no dependencies on services or UI.
- Name test functions descriptively: `func fetchItems_returnsEmpty_whenNoData()`.

### Running Tests
```bash
# TODO: Replace with your project's scheme and destination
xcodebuild test \
    -project YourApp.xcodeproj \
    -scheme YourApp \
    -destination 'platform=iOS Simulator,name=iPhone 16'
```

---

## 15. Code Style

### Guide
- Follow [Airbnb's Swift Style Guide](https://github.com/airbnb/swift).
- Use `camelCase` for variables/functions, `PascalCase` for types.
- Use `// MARK: -` to organize code sections: `Properties`, `Intents`, `Private`, etc.
- Use extension-based organization to separate concerns within a file.

### File Naming
| Type | Pattern | Example |
|---|---|---|
| View | `SomeNameView.swift` | `ProfileView.swift` |
| ViewModel | `SomeNameViewModel.swift` | `ProfileViewModel.swift` |
| Service | `SomeNameService.swift` | `ProfileService.swift` |
| Repository | `SomeNameRepository.swift` | `SubscriptionRepository.swift` |
| Model | Descriptive domain name | `Product.swift`, `UserProfile.swift` |

### Feature Folder Structure
```
SomeFeature/
├── View/
│   ├── SomeFeatureView.swift
│   ├── SomeFeatureView+Toolbar.swift
│   └── SomeFeatureView+Sheets.swift
├── ViewModel/
│   └── SomeFeatureViewModel.swift
└── Model/
    └── SomeModel.swift
```

### Imports & Dependencies
- Import only necessary frameworks.
- Prefer SwiftUI-native solutions over third-party libraries.
- Prefer Swift concurrency (async/await) over Combine.

---

## 16. General Rules for Code Generation

- Read existing code before modifying it.
- Make the fewest changes possible to accomplish the task.
- Ensure code compiles after each step.
- Do not add comments, docstrings, or type annotations to code you didn't change.
- Do not add error handling for scenarios that cannot happen.
- Do not create abstractions for one-time operations.
- Avoid deprecated APIs.
- Prioritize security: no command injection, no hardcoded secrets, validate at system boundaries.
- If you lack context, ask before proceeding.

---

## TODO: Project-Specific Customization

When adopting this template for a new project, fill in:

1. **Project Overview** — App purpose, specific tech stack, third-party SDKs
2. **Project Structure** — Actual folder tree
3. **Backend Details** — API type (REST, GraphQL, Supabase, Firebase), auth method
4. **Supported Languages** — For localization section
5. **Test Command** — Project name, scheme, simulator
6. **Design System** — Actual component names from your CoreUI
7. **Service Suffix** — Adjust naming if not using Supabase (e.g., `SomeNameAPIService`)
