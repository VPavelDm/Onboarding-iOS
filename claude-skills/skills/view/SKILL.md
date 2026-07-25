---
name: view
description: Use when creating or modifying any SwiftUI View — struct composition from small named subviews, ViewModel ownership, UI-only local state, events out via closures, lifecycle wiring, design-system styling, and previews. Triggers on any edit to *View.swift files (except trivial edits — typos, renames, constants).
---

# Views

Views render state and forward user intent to their ViewModel. No business logic, no data access. Navigation may live in the View — it only moves out (as injected closures) when the same View is reused from contexts that navigate differently.

## Shape of a View

```swift
/// Pure playback view: plays a session and reports completion via `onFinish`.
/// The parent decides what happens next (push a recap, advance the flow, …).
struct PlayerView: View {
    @State private var viewModel: PlayerViewModel
    @State private var isEndConfirmationPresented = false

    /// Called when the session ends — naturally or via "End" in the confirmation.
    private let onFinish: () -> Void

    init(
        affirmations: [Affirmation],
        speech: AffirmationSpeechServiceProtocol = ElevenLabsAffirmationSpeechService(),
        onFinish: @escaping () -> Void
    ) {
        self._viewModel = State(
            initialValue: PlayerViewModel(affirmations: affirmations, speech: speech)
        )
        self.onFinish = onFinish
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 24) {
                affirmationText
                actionRow
            }
            .frame(maxHeight: .infinity)
            playerControls
        }
        .animation(.easeInOut(duration: 0.35), value: viewModel.currentIndex)
        .padding(.horizontal, 20)
        .background(OnboardingAuraBackground())
        .onAppear { viewModel.begin() }
        .onDisappear { viewModel.endSession() }
        .onChange(of: viewModel.isFinished) { _, finished in
            if finished { onFinish() }
        }
        .alert("End session?", isPresented: $isEndConfirmationPresented) {
            Button("End", role: .destructive) { viewModel.endSessionEarly() }
            Button("Keep going", role: .cancel) {}
        }
    }

    private var actionRow: some View { … }
    private var playerControls: some View { … }
    private var affirmationText: some View { … }
}
```

Canonical live example: `Affirmations/Player/View/PlayerView.swift`.

## Rules

### Ownership & state
- The View owns its ViewModel: `@State private var viewModel`, built in `init` via `State(initialValue:)` from the init parameters (see the `viewmodel` skill).
- Dependencies flow through the View's init with default parameters (`speech: … = ElevenLabsAffirmationSpeechService()`) and are handed straight to the ViewModel — parents, previews, and tests override with Fakes.
- UI-only state stays in the View as separate `@State` (`isEndConfirmationPresented`, focus, sheet toggles). If it survives the screen or another layer needs it, it belongs in the ViewModel instead.

### Events & navigation
- Every user action calls a ViewModel method (`viewModel.togglePlayPause()`); the View never mutates domain state itself.
- Navigation logic is allowed in the View by default — push, present, dismiss where the outcome is handled.
- When a View is reused from multiple contexts that navigate differently (PlayerView runs inside both onboarding and home), the navigation moves out: outcomes leave through injected, doc-commented closures (`onFinish: () -> Void`) and each parent decides what happens next.
- ViewModel outcomes that must reach the parent are observed with `.onChange(of:)` on ViewModel state, which then fires the closure.

### Composition
- `body` is a short layout of **named private computed subviews** (`affirmationText`, `actionRow`, `playerControls`, `closeButton`) — every logical block gets a name. Small repeated pieces become private functions (`actionIcon(_:size:)`).
- Split into a separate `View` struct only when the piece needs its own state or is reused; otherwise stay with private vars in the same file.
- `@ViewBuilder` on a subview only when it actually branches.

### Lifecycle
- `.onAppear { viewModel.begin() }` / `.onDisappear { viewModel.endSession() }` (or `.task` for async begin). Lifecycle goes to the ViewModel as intent — the View doesn't start timers or requests itself.

### Styling
- Shared `ButtonStyle`s for every button (`IconButtonStyle`, `PlayerControlButtonStyle`, `PlayButtonStyle(.large)`) — no inline ad-hoc button styling.
- Design-system color assets used directly (`.slateBlue`, `.lavenderGray`) — no intermediary color constants.
- Font modifiers per block; a shared `.fontDesign(…)` applied once at the root when the screen uses one design throughout.
- All user-facing strings localized.

### Layout & motion polish
- Reserve space for variable-length content so swaps never shove siblings around (fixed-height frame with `alignment:`, `minimumScaleFactor` + `lineLimit` for long text).
- Live-updating numbers get `.monospacedDigit()`; timers render via `Text(timerInterval:countsDown:)` with `.fixedSize()`, not manual ticking.
- Animate by state value: `.animation(_, value:)` scoped to the driving property; content swaps via `.id(…)` + `.transition(…)`. Continuous drawing (progress rings) wraps in `TimelineView(.animation)`.
- Comments state constraints the code can't show ("reserve space so swaps never resize this block"), not what the next line does.

## Previews

Every View gets a `#Preview` with realistic demo content, wired so it renders without network — pass Fake services (see the `service` skill) when the default dependency would hit the real backend. Match the app's expected color scheme when it matters (`.preferredColorScheme(.dark)`).
