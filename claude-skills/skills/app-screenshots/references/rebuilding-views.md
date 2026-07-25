# Rebuilding views (the isolation rule)

The single most important invariant: **never modify production code to make screenshots
work**, and **match the real app UI by default.** Get each screen from an isolated
`Screenshots/` group in one of two ways:

- **Reuse the real view (preferred)** when it accepts injected demo data — a model value, a
  `Binding`, a closure — and renders without spinning up its own view-model or network. This
  guarantees pixel-identical UI. (e.g. a `DetailView(item:)`, or a step view that takes
  `@Binding var date` + `onSave` closure.)
- **Reproduce the layout** in a fresh view when the screen owns its view-model (e.g. a
  `ComposeView` with `@State var vm = ComposeViewModel()` that can't be injected). Then copy
  its structure faithfully and compose the real *pure* subcomponents (rows, tiles, toolbars,
  button styles) fed with demo data.

Either way you get: **safety** (production code untouched — impossible to ship a bug),
**fidelity** (looks like the app), and **determinism** (no live network/clock/store; renders
identically every run and locale). Reusing pure subcomponents is not "reaching into the app"
— it's using them exactly as the app does, just with demo data.

## What "isolated" means concretely

A screenshot view MAY:
- Copy colors, fonts, corner radii, spacing, gradients, and asset names from the real screen
  (or better, share a *design-system* module that has no logic — e.g. `Color.cream`, a
  `PrimaryButtonStyle`). Sharing pure styling is fine; sharing behavior is not.
- Re-declare small layout structs locally (a card, a chip, a tile) rather than import the
  real ones if the real ones drag in dependencies.

A screenshot view MUST NOT:
- Import or instantiate a production **view-model**, **service**, **repository**, or
  **store** (`CapsuleService`, `OnboardingViewModel`, Supabase client, SwiftData `Query`…).
- Trigger **network**, **auth**, **analytics**, **StoreKit/Adapty**, or **notifications**.
- Depend on real **navigation** or app **launch flow** (onboarding, paywall gating).
- Read live time/date, random values, or device state.

If reproducing a screen would require copying a lot of real layout, prefer extracting the
**pure visual pieces** into a shared, logic-free view (usable by both app and screenshots)
over importing the stateful screen. But when in doubt, **copy the markup into the
screenshot view** — a little duplication is the price of zero risk.

## Anatomy

```
Screenshots/                         # one isolated group, added to the app target
  ScreenshotMode.swift               # flag + screen enum + localized demo accessors
  ScreenshotRootView.swift           # routes to a screen by launch arg; sets colorScheme/type
  ScreenshotHomeView.swift           # standalone reproduction, seeded demo state
  ScreenshotComposeView.swift
  ScreenshotDetailView.swift
  …
  Screenshots.xcstrings              # localized demo content (table "Screenshots")
```

Each `ScreenshotXView` is `some View` with **hard-coded / injected demo state**:

```swift
struct ScreenshotHomeView: View {
    // Seeded in-memory — no store, no network.
    private let capsules = ScreenshotMode.demoCapsules
    var body: some View {
        ZStack { /* reproduce the home layout with `capsules` */ }
    }
}
```

Demo model values are plain in-memory structs. If the real model type is a pure value type
with a public initializer (no side effects), reuse it; otherwise define a tiny local
`DemoCapsule`. Reuse an existing `*+TestData.swift` if the app already has preview fixtures.

## Match the real screen EXACTLY by default

The reproduction must look identical to the real app screen — same layout, components,
spacing, chrome, and styling. The rebuild is for **isolation only** (no VM/service/network
dependency); it is **not** license to restyle. Read the real view and copy its structure and
modifiers faithfully into the standalone view, then feed it demo data. Pixel-parity with the
app is the default and the bar.

Do NOT simplify, drop elements, re-lay-out, or take "marketing" liberties on your own. If a
screen looks too busy or you think a caption would sell better, **propose it** — don't change
it silently.

### Reproduce EVERY section of the screen
A screen is often several stacked sections (header + hero + list + toolbar). Reproduce **all**
of them. The most common mistake: a screen has one section whose subview *seems* to need a
view-model, so you drop that whole section — leaving a screenshot that's missing a chunk of
the real UI. That's a silent deviation and is forbidden. Instead:

1. **Check whether the subview actually uses the view-model.** Very often a row/cell takes a
   `viewModel` parameter it never reads in `body` (it renders from the item/model). If so,
   copy its `body` verbatim into a standalone view that takes only the model — identical UI,
   no VM. (Real example: a home list row declared `var viewModel: HomeViewModel` but rendered
   purely from `capsule` — trivially reproducible.)
2. **If it genuinely needs state**, reconstruct just the data it reads (a plain value) and
   feed it; still reproduce the section.
3. **Only omit a section if the user explicitly asks** for a cleaner shot.

### Fidelity self-check (do this before declaring a shot done)
Open the real screen (run the app, or read its source) and the screenshot side by side and
confirm: every section present, same order, same components, same chrome (nav title,
toolbar buttons), same fonts/spacing, same background. A missing filter bar, list, tab bar,
or nav button means the reproduction is wrong — not "cleaner".

### Deviate ONLY when the user asks (per screen)
When the user explicitly requests a change for a given shot, then you may:
- **Strip chrome** (a back button, a debug badge, an empty toolbar).
- **Force a state** — a full home instead of empty, a subscribed user (no lock icons).
- **Enlarge type** for thumbnail legibility, or **pin appearance** for a system-styled subview.
- **Freeze motion** — a static frame instead of an animated ring/aura (the UITest runs
  `waitForAnimations: false` because continuous animation never quiesces).

Seeding a "full/good" data state is normal and expected (that's demo content, not a UI
change). Changing how the UI itself is drawn is what requires a request.

## Reachability

Only `ScreenshotRootView` is behind the flag; the views themselves are just Swift files in
the target. They compile in every build but are never presented in production (nothing
references them outside `ScreenshotRootView`, which is only shown when
`ScreenshotMode.isEnabled`). No `#if DEBUG` is required, and it keeps the release build's
UI path identical — but you MAY wrap the whole group in `#if DEBUG` if the app must never
ship the demo strings. Decide per app; default is no `#if` (simpler, harmless).
