# onboarding-ios

A drop-in SwiftUI onboarding library for iOS. Describe your onboarding flow in **JSON**, point the library at it, and implement a small `OnboardingDelegate` to receive answers. Ships with 17 built-in step types (welcome, single/multi-select, pickers, progress, social proof, discount wheel, feature showcase, and more), full theming, branching, localization, and custom step support.

- **Platforms:** iOS 16+
- **Swift:** 5.10+
- **UI:** SwiftUI
- **Integration model:** JSON-driven flow + Swift delegate callbacks

---

## Installation

Add the package via Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/VPavelDm/Onboarding-iOS.git", from: "1.0.0")
]
```

Then depend on the `Onboarding` product in your target:

```swift
.target(name: "YourApp", dependencies: [
    .product(name: "Onboarding", package: "Onboarding-iOS")
])
```

### Other products

The package also vends these libraries (use only what you need):

| Product | Purpose |
| --- | --- |
| `Onboarding` | The main onboarding engine (this README) |
| `Paywalls` | Adapty SDK wrapper for paywalls |
| `Profile` | Reusable profile UI |
| `CoreUI` | Shared UI primitives |
| `CoreAnalytics` | Analytics abstraction |
| `CoreNetwork` | Networking primitives |
| `CoreStorage` | Persistence primitives |
| `GPTApi` | OpenAI API wrapper |

---

## Quickstart

**1.** Add `onboarding.json` to your app bundle:

```json
[
  {
    "id": "welcome",
    "type": "welcome",
    "payload": {
      "title": "Welcome to MyApp",
      "description": "Let's get you set up.",
      "emojis": ["👋", "🎉", "🚀"],
      "firstAnswer": {
        "title": "Get started",
        "nextStepID": "pick_goal"
      }
    }
  },
  {
    "id": "pick_goal",
    "type": "oneAnswer",
    "payload": {
      "title": "What's your goal?",
      "buttonTitle": "Continue",
      "answers": [
        { "title": "Lose weight", "payload": { "type": "string", "value": "lose" } },
        { "title": "Build muscle", "payload": { "type": "string", "value": "muscle" } },
        { "title": "Stay healthy", "payload": { "type": "string", "value": "healthy" } }
      ]
    }
  }
]
```

**2.** Implement `OnboardingDelegate`:

```swift
import Onboarding

@MainActor
final class MyOnboardingDelegate: OnboardingDelegate {
    func onAnswer(userAnswer: UserAnswer, allAnswers: [UserAnswer]) async {
        switch userAnswer.onboardingStepID {
        case "pick_goal":
            if case .string(let goal) = userAnswer.payloads.first {
                print("User goal: \(goal)")
            }
        default:
            break
        }
    }
}
```

**3.** Implement a `ColorPalette`:

```swift
import SwiftUI
import Onboarding

struct AppColors: ColorPalette {
    var textColor: Color = .black
    var secondaryTextColor: Color = .secondary
    var primaryButtonForegroundColor: Color = .white
    var primaryButtonBackground: AnyShapeStyle = AnyShapeStyle(Color.blue)
    var secondaryButtonForegroundColor: Color = .blue
    var secondaryButtonBackground: AnyShapeStyle = AnyShapeStyle(Color.white)
    var secondaryButtonStrokeColor: Color = .blue
    var plainButtonColor: Color = .primary
    var progressBarBackgroundColor: AnyShapeStyle = AnyShapeStyle(Color.gray.opacity(0.2))
    var orbitColor: Color = .gray.opacity(0.2)
    var accentColor: Color = .blue
}
```

**4.** Present `OnboardingView`:

```swift
import SwiftUI
import Onboarding

struct RootView: View {
    private let delegate = MyOnboardingDelegate()

    var body: some View {
        OnboardingView(
            configuration: OnboardingConfiguration(
                url: Bundle.main.url(forResource: "onboarding", withExtension: "json")!
            ),
            delegate: delegate,
            colorPalette: AppColors(),
            customStepView: { _ in EmptyView() } // no custom steps in this flow
        )
    }
}
```

That's it.

---

## Core concepts

The library has three integration points:

1. **`OnboardingConfiguration`** — tells the library where to load the JSON from (and optional localization table).
2. **`OnboardingDelegate`** — the `@MainActor` protocol your app implements to receive answers.
3. **`ColorPalette`** — the protocol your app implements to theme the UI.

You embed everything in a single SwiftUI view: `OnboardingView`.

### OnboardingView

```swift
public struct OnboardingView<CustomStepView: View>: View {
    public init(
        configuration: OnboardingConfiguration,
        delegate: OnboardingDelegate,
        colorPalette: any ColorPalette,
        @ViewBuilder customStepView: @escaping (CustomStepParams) -> CustomStepView
    )
}
```

The `customStepView` builder is only used for steps of type `"custom"`. If you don't use custom steps, return `EmptyView()`.

### OnboardingConfiguration

```swift
public struct OnboardingConfiguration {
    public init(url: URL, bundle: Bundle = .main, tableName: String? = nil)
}
```

- `url` — file or remote URL of the JSON.
- `bundle` — bundle used for image assets **and** `NSLocalizedString` lookup (default: `.main`).
- `tableName` — optional `.strings`/`.xcstrings` table name for localization.

### OnboardingDelegate

```swift
@MainActor
public protocol OnboardingDelegate {
    func format(string: String) -> String       // optional — default returns input
    func onAnswer(userAnswer: UserAnswer, allAnswers: [UserAnswer]) async
}

public struct UserAnswer: Sendable, Equatable, Hashable {
    public var onboardingStepID: StepID          // the step id from JSON
    public var payloads: [Payload]

    public enum Payload: Sendable, Equatable, Hashable {
        case string(String)
        case json(Data)
        public var string: String? { ... }
        public var data: Data? { ... }
    }
}

public typealias StepID = String
```

- `onAnswer` fires every time the user completes a step (including no-input steps like `welcome` and `description` — the `payloads` will just be empty).
- `allAnswers` is the accumulated history of every answer so far — useful for branching, validation, or derived state.
- `format(string:)` runs on every user-visible string. Use it for templating (e.g. replacing `{name}` with a value the user entered earlier) or brand-specific transforms.

---

## JSON schema

The JSON is an **array** of step objects:

```jsonc
[
  {
    "id": "my_step",         // unique StepID (String)
    "type": "oneAnswer",     // one of the types listed below
    "payload": { ... }       // type-specific payload
  },
  ...
]
```

### Shared types

**StepAnswer** — every step that has a button or selectable option uses this:

```jsonc
{
  "title": "Continue",          // button label (or option label)
  "icon": "star.fill",          // optional — SF Symbol name OR asset name
  "nextStepID": "next_step",    // optional — advance to this step on tap
  "payload": {                  // optional — user data attached to this answer
    "type": "string",           // "string" | "json"
    "value": "lose_weight"      // String for "string", base64 Data for "json"
  }
}
```

**ImageResponse** — used by steps that render an image:

```jsonc
{
  "type": "named",              // "named" | "remote"
  "value": "hero",              // asset name OR https URL
  "aspectRatioType": "fit"      // "fit" | "fill"
}
```

---

## Step type reference

Below is the complete set of built-in step types. Payload fields are required unless marked optional.

### `welcome`

Title, description, emojis, and 1–2 buttons.

```jsonc
{
  "id": "welcome",
  "type": "welcome",
  "payload": {
    "title": "Welcome",
    "description": "Let's begin.",
    "emojis": ["👋", "🎉"],
    "firstAnswer":  { "title": "Start",       "nextStepID": "step_a" },
    "secondAnswer": { "title": "Sign in",     "nextStepID": "step_b" }  // optional
  }
}
```

### `welcomeFade`

Cinematic fade-through of messages.

```jsonc
{
  "id": "welcome_fade",
  "type": "welcomeFade",
  "payload": {
    "messages": ["Hi.", "Nice to meet you.", "Let's go."],
    "delay": 1.5
  }
}
```

### `oneAnswer`

Single-select from a list. Submit button at the bottom.

```jsonc
{
  "id": "pick_goal",
  "type": "oneAnswer",
  "payload": {
    "title": "What's your goal?",
    "description": "Pick one.",                    // optional
    "image": { ... },                              // optional
    "buttonTitle": "Continue",
    "autoNavigateOnSingleAnswer": true,            // optional — skip submit button if exactly one answer tappable
    "skip": { "title": "Skip", "nextStepID": "..." }, // optional
    "answers": [
      { "title": "Option A", "payload": { "type": "string", "value": "a" } },
      { "title": "Option B", "payload": { "type": "string", "value": "b" } }
    ]
  }
}
```

### `binaryAnswer`

Two explicit buttons (e.g. Yes/No).

```jsonc
{
  "id": "notifications",
  "type": "binaryAnswer",
  "payload": {
    "title": "Enable notifications?",
    "description": "We'll remind you.",            // optional
    "firstAnswer":  { "title": "Allow",     "nextStepID": "step_x" },
    "secondAnswer": { "title": "Not now",   "nextStepID": "step_x" }
  }
}
```

### `multipleAnswer`

Checklist with minimum-count validation.

```jsonc
{
  "id": "pick_interests",
  "type": "multipleAnswer",
  "payload": {
    "title": "Pick your interests",
    "description": "Choose at least 2.",           // optional
    "image": { ... },                              // optional
    "buttonTitle": "Continue",
    "minAnswersAmount": 2,
    "answers": [
      { "title": "Running",  "payload": { "type": "string", "value": "running" } },
      { "title": "Cycling",  "payload": { "type": "string", "value": "cycling" } },
      { "title": "Swimming", "payload": { "type": "string", "value": "swim"    } }
    ]
  }
}
```

The delegate receives one `UserAnswer` with `payloads` containing all selected options.

### `description`

Image + title + description + single button.

```jsonc
{
  "id": "intro",
  "type": "description",
  "payload": {
    "title": "Here's how it works",
    "description": "Swipe through the cards.",     // optional
    "image": { ... },                              // optional
    "answer": { "title": "Got it", "nextStepID": "..." }
  }
}
```

### `featureShowcase`

Big feature image with a hex background color.

```jsonc
{
  "id": "feature_ai",
  "type": "featureShowcase",
  "payload": {
    "title": "Track smarter with AI",
    "description": "Snap a photo, get instant info.", // optional
    "image": { "type": "named", "value": "showcase", "aspectRatioType": "fit" },
    "backgroundColor": "1A1A1A",                   // 6- or 8-digit hex, no "#"
    "answer": { "title": "Continue", "nextStepID": "..." }
  }
}
```

### `socialProof`

Testimonial + user review + stats grid.

```jsonc
{
  "id": "proof",
  "type": "socialProof",
  "payload": {
    "image": { ... },
    "welcomeHeadline": "Loved by 2M+ users",
    "welcomeSubheadline": "Across 80 countries",
    "userReview": "★★★★★",
    "stats": [
      { "value": "2M+", "label": "users" },
      { "value": "4.9", "label": "rating" }
    ],
    "message": "This app changed my routine.",
    "messageAuthor": "— Anna, New York",
    "answer": { "title": "Continue", "nextStepID": "..." }
  }
}
```

### `progress`

Progress bar with animated steps over a duration.

```jsonc
{
  "id": "setting_up",
  "type": "progress",
  "payload": {
    "title": "Setting up your plan",
    "description": "This won't take long.",        // optional
    "duration": 3.0,
    "steps": ["Analyzing answers", "Building plan", "Personalizing"],
    "answer": { "title": "Continue", "nextStepID": "..." }
  }
}
```

### `timePicker`

Wheel time picker.

```jsonc
{ "id": "wake_time", "type": "timePicker",
  "payload": { "title": "When do you wake up?", "answer": { "title": "Continue", "nextStepID": "..." } } }
```

### `heightPicker` / `weightPicker`

Metric/imperial toggle + wheel picker.

```jsonc
{
  "id": "height",
  "type": "heightPicker",
  "payload": {
    "title": "Your height",
    "description": "We'll use this to personalize.", // optional
    "metricUnit": "cm",
    "imperialUnit": "ft",
    "answer": { "title": "Continue", "nextStepID": "..." }
  }
}
```

Same shape for `weightPicker` (use `kg`/`lb`).

### `agePicker`

Single-unit age picker.

```jsonc
{
  "id": "age",
  "type": "agePicker",
  "payload": {
    "title": "Your age",
    "description": "We promise — for personalization only.", // optional
    "unit": "years",
    "answer": { "title": "Continue", "nextStepID": "..." }
  }
}
```

### `enterValue`

Text field with a primary and optional skip answer.

```jsonc
{
  "id": "enter_name",
  "type": "enterValue",
  "payload": {
    "title": "What's your name?",
    "description": "We'll use this to personalize.", // optional
    "image": { ... },                                // optional
    "placeholder": "Your name",
    "valueType": "text",                             // "text" | "number" | ...
    "primaryAnswer": { "title": "Continue", "nextStepID": "..." },
    "skipAnswer":    { "title": "Skip",     "nextStepID": "..." } // optional
  }
}
```

The user's input is delivered via `UserAnswer.payloads` as a single `.string(...)` payload.

### `discountWheel`

Gamified spin-to-win wheel.

```jsonc
{
  "id": "discount",
  "type": "discountWheel",
  "payload": {
    "title": "Spin for your discount",
    "spinButtonTitle": "Spin",
    "spinFootnote": "Everyone wins something.",
    "successTitle": "You won 20% off!",
    "successDescription": "Valid for the next 24 hours.",
    "answer": { "title": "Claim", "nextStepID": "..." }
  }
}
```

### `widget`

Reserved container for a labelled image card.

```jsonc
{
  "id": "widget",
  "type": "widget",
  "payload": {
    "title": "Your widget",
    "description": "Shows up on your home screen.",
    "image": { ... },                                // optional
    "answer": { "title": "Continue", "nextStepID": "..." }
  }
}
```

### `custom`

See [Custom steps](#custom-steps) below.

---

## Custom steps

When a step's `type` is `"custom"`, the library renders your SwiftUI view instead of a built-in component. You opt in via the `customStepView` builder on `OnboardingView`.

**JSON:**

```jsonc
{
  "id": "my_custom_screen",
  "type": "custom",
  "payload": {
    "nextStepID": "after_custom",             // optional — default next step
    "branches": {                              // optional — named branches
      "free":    "free_plan_screen",
      "premium": "premium_plan_screen"
    }
  }
}
```

**Swift:**

```swift
OnboardingView(
    configuration: config,
    delegate: delegate,
    colorPalette: colors,
    customStepView: { params in
        switch params.currentStepID {
        case "my_custom_screen":
            MyCustomScreen(onFinish: { branch in
                Task { await params(branch: branch) } // advance to branches[branch] (or default nextStepID)
            })
        default:
            EmptyView()
        }
    }
)
```

**CustomStepParams:**

```swift
public struct CustomStepParams: Sendable, Hashable {
    public var currentStepID: StepID

    // Call to advance. `branch` is looked up in the step's `branches` map.
    // If missing (or nil), the step's default `nextStepID` is used.
    public func callAsFunction(
        branch: String? = nil,
        payloads: [UserAnswer.Payload] = []
    ) async
}
```

`params(...)` calls the delegate's `onAnswer` with the supplied payloads and navigates. Always `await` it — it returns after navigation completes.

---

## Branching

There are **two** ways to control navigation between steps:

### 1. Per-answer `nextStepID`

Each `StepAnswer` (buttons, options, skip, etc.) can carry its own `nextStepID`. Different answers → different next steps. This is the simplest form of branching.

```jsonc
"answers": [
  { "title": "Yes", "nextStepID": "ask_details" },
  { "title": "No",  "nextStepID": "summary"     }
]
```

### 2. Named branches on custom steps

For flows where branching depends on logic only the host knows (e.g. server response, subscription state), use a `custom` step with `branches`:

```jsonc
{ "id": "gate", "type": "custom",
  "payload": { "branches": { "paying": "thanks", "free": "paywall" } } }
```

```swift
Task { await params(branch: subscribed ? "paying" : "free") }
```

---

## Theming

Implement `ColorPalette` to theme every rendered surface:

```swift
public protocol ColorPalette {
    var textColor: Color { get }
    var secondaryTextColor: Color { get }
    var primaryButtonForegroundColor: Color { get }
    var primaryButtonBackground: AnyShapeStyle { get }
    var secondaryButtonForegroundColor: Color { get }
    var secondaryButtonBackground: AnyShapeStyle { get }
    var secondaryButtonStrokeColor: Color { get }
    var plainButtonColor: Color { get }
    var progressBarBackgroundColor: AnyShapeStyle { get }
    var orbitColor: Color { get }
    var accentColor: Color { get }
}
```

Use `AnyShapeStyle(Color(...))` or `AnyShapeStyle(LinearGradient(...))` for the shape-style properties to support gradients or plain colors interchangeably.

Typography is system fonts only (no injection point). If you need custom fonts, wrap `OnboardingView` in a `.environment(\.font, ...)`-style modifier chain.

---

## Localization

Every string field in the JSON is treated as a **localization key**. At load time the library resolves it via:

```swift
NSLocalizedString(key, tableName: <config.tableName>, bundle: <config.bundle>, value: key, comment: "")
```

- If a matching key exists in your `.strings` / `.xcstrings`, the translated value is used.
- If not, the original JSON string is used as-is — so plain English keys work out of the box.

To use a custom table (e.g. `Onboarding.strings`):

```swift
OnboardingConfiguration(
    url: url,
    bundle: .main,
    tableName: "Onboarding"
)
```

### Runtime string formatting

`OnboardingDelegate.format(string:)` runs on every rendered string after localization. Use it for templating:

```swift
func format(string: String) -> String {
    string.replacingOccurrences(of: "{name}", with: capturedName)
}
```

Then in JSON:

```jsonc
"title": "Hi {name}, let's set you up."
```

---

## Images

Every `image` field uses the `ImageResponse` shape:

```jsonc
{ "type": "named",  "value": "hero_image", "aspectRatioType": "fit" }
{ "type": "remote", "value": "https://cdn.example.com/hero.png", "aspectRatioType": "fill" }
```

- `"named"` — looks up the asset in `configuration.bundle` (defaults to `.main`). **The asset must exist in your app's asset catalog** (or a bundle catalog you pass in).
- `"remote"` — loaded over the network via `AsyncImage`.
- `aspectRatioType` — `"fit"` or `"fill"`.

Icons on `StepAnswer` (the optional `icon` field) accept **either** an SF Symbol name or an asset name.

---

## Handling answers in the delegate

`onAnswer` fires once per step completion. Dispatch by `onboardingStepID`:

```swift
func onAnswer(userAnswer: UserAnswer, allAnswers: [UserAnswer]) async {
    switch userAnswer.onboardingStepID {
    case "enter_name":
        let name = userAnswer.payloads.first?.string ?? ""
        await profileService.save(name: name)

    case "pick_interests":
        let interests = userAnswer.payloads.compactMap(\.string)
        await profileService.save(interests: interests)

    case "finish":
        await profileService.markOnboardingComplete()

    default:
        break
    }
}
```

### Reading past answers

`allAnswers` gives you the full history for derived state:

```swift
let name = allAnswers
    .first { $0.onboardingStepID == "enter_name" }?
    .payloads.first?.string ?? ""
```

---

## Remote JSON

`OnboardingConfiguration.url` can be a remote HTTPS URL. The library will download the JSON at first display. Common pattern: ship a bundled fallback and optionally swap for a server-driven flow behind a feature flag.

```swift
let url = remoteEnabled
    ? URL(string: "https://cdn.example.com/onboarding.json")!
    : Bundle.main.url(forResource: "onboarding", withExtension: "json")!
```

---

## Full API surface

```swift
// Entry point
public struct OnboardingView<CustomStepView: View>: View {
    public init(
        configuration: OnboardingConfiguration,
        delegate: OnboardingDelegate,
        colorPalette: any ColorPalette,
        @ViewBuilder customStepView: @escaping (CustomStepParams) -> CustomStepView
    )
}

// Configuration
public struct OnboardingConfiguration {
    public init(url: URL, bundle: Bundle = .main, tableName: String? = nil)
}

// Delegate
@MainActor
public protocol OnboardingDelegate {
    func format(string: String) -> String                  // optional, default returns input
    func onAnswer(userAnswer: UserAnswer, allAnswers: [UserAnswer]) async
}

// User answer
public typealias StepID = String

public struct UserAnswer: Sendable, Equatable, Hashable {
    public var onboardingStepID: StepID
    public var payloads: [Payload]
    public enum Payload { case string(String), json(Data) }
}

// Custom steps
public struct CustomStepParams: Sendable, Hashable {
    public var currentStepID: StepID
    public func callAsFunction(
        branch: String? = nil,
        payloads: [UserAnswer.Payload] = []
    ) async
}

// Theming
public protocol ColorPalette {
    var textColor: Color { get }
    var secondaryTextColor: Color { get }
    var primaryButtonForegroundColor: Color { get }
    var primaryButtonBackground: AnyShapeStyle { get }
    var secondaryButtonForegroundColor: Color { get }
    var secondaryButtonBackground: AnyShapeStyle { get }
    var secondaryButtonStrokeColor: Color { get }
    var plainButtonColor: Color { get }
    var progressBarBackgroundColor: AnyShapeStyle { get }
    var orbitColor: Color { get }
    var accentColor: Color { get }
}
```

---

## Integration checklist

- [ ] Package added via SPM
- [ ] `onboarding.json` in the app bundle (or a reachable remote URL)
- [ ] All image `"named"` assets exist in the asset catalog
- [ ] `OnboardingDelegate` handles every `onboardingStepID` you care about
- [ ] `ColorPalette` implemented with real brand colors (all 11 properties set)
- [ ] `customStepView` builder returns `EmptyView()` or a real view if you use `custom` steps
- [ ] Localization `.strings`/`.xcstrings` file added if you use localization keys
- [ ] You advance the app out of onboarding yourself (e.g. on a terminal step's `onAnswer`) — the library does not dismiss itself

---

## Gotchas

1. **Unknown step types are silently dropped.** If a `type` string doesn't match any built-in type (and isn't `"custom"`), the step is filtered out at load time. Typos won't raise errors.

2. **`@MainActor` required on the delegate.** The protocol is `@MainActor`-isolated; your implementation must be too.

3. **`backgroundColor` hex has no `#`.** Use `"1A1A1A"` or `"FF1A1A1A"` (8 digits = AARRGGBB).

4. **`params()` on custom steps is async.** Always `await` it. Calling without `await` is a no-op.

5. **Dismissing onboarding is the host's responsibility.** `OnboardingView` doesn't pop itself. Trigger navigation in your `onAnswer` when `onboardingStepID` matches your terminal step.

6. **The flow starts at the first step in the array.** There's no explicit `startStepID`. Order your JSON accordingly.

7. **Remote JSON has no retry UI.** If the fetch fails, the view stays on its loading state. Prefer bundled JSON unless you have a fallback.

---

## License

See `LICENSE` in the repository.
