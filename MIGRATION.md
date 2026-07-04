# Migrating from 2.1 to 2.2

**2.2 moves localization out of the library and into the host app.** The flow is now
language-agnostic: JSON strings are treated as **raw keys**, and each step view asks the host
to resolve them at render time through `OnboardingDelegate.format(string:)`. This lets the app
change language mid-flow — the next screen renders in the new language with no restart — and
keeps the library from bundling any `NSLocalizedString`/bundle logic of its own.

## ⚠️ Verify your onboarding copy after upgrading

Because resolution now runs through your `format(string:)`, **test every step type in every
language you ship.** If `format` doesn't resolve a key, that string renders as the **raw key**.
Walk the whole flow per language and confirm all titles, descriptions, answer titles, button
titles, units, and list labels are translated.

## What changed

- Before: the library localized copy **at parse time** via an internal `Localizer`
  (`NSLocalizedString` against `configuration.bundle` / `tableName`). Language was fixed once,
  at load.
- Now: models store **raw keys**; step views localize **at render** via the delegate. Language
  can change between steps.

## Action required

1. **Implement `format(string:)` to localize.** It already existed for placeholder substitution;
   now it must also translate the key. To reproduce the old behavior:

   ```swift
   func format(string key: String) -> String {
       let localized = NSLocalizedString(key, bundle: myBundle, value: key, comment: "")
       return localized // + any {placeholder} substitution you already do
   }
   ```

   `configuration.bundle` / `tableName` are no longer used by the library for localization — do
   your own lookup here.

2. **To render in a language other than the device's,** have `format` resolve into that language
   (it's the single localization seam for built-in steps). For your own **custom** step views,
   implement the optional `preferredLanguageCode()` — `OnboardingView` applies it as the subtree's
   environment locale, so `Text`/`LocalizedStringKey` in custom steps resolve into that language:

   ```swift
   func preferredLanguageCode() -> String? { chosenLanguageCode } // e.g. "ru"
   ```

   A language chosen mid-flow takes effect on the **next** step, not the current one: `OnboardingView`
   re-reads `preferredLanguageCode()` only when the step changes, so the outgoing screen keeps the old
   language until it's replaced (no flash). Built-in steps re-resolve through `format`; custom steps
   through this locale. Return `nil` (the default) to follow the ambient environment locale.

## Notes

- The internal `Localizer` type was removed (it was not public API).
- No changes to `OnboardingView`, `ColorPalette`, routing, or custom-step wiring.

## Update your version pin

```swift
.package(url: "https://github.com/VPavelDm/Onboarding-iOS.git", from: "2.2.0")
```

---

# Migrating from 2.0 to 2.1

**2.1 adds Android support** to the onboarding library via [Skip Fuse](https://skip.tools).
The same JSON-driven flow and `OnboardingDelegate` now run on both iOS and Android from
one Swift codebase. For existing **iOS-only** consumers this is a low-effort upgrade — the
public integration API is source-compatible — but the package manifest changed, so there are
a few one-time steps.

## TL;DR

- Bump your app's deployment target to **iOS 17 / macOS 14**.
- Let SPM re-resolve — three new dependencies are pulled in (`skip`, `skip-fuse-ui`, `OpenCombine`).
- The `Onboarding` and `CoreUI` targets now carry the **skipstone** build plugin; approve it the
  first time Xcode/SPM asks. (iOS-only builds don't need the Skip toolchain.)
- No source changes are required for standard `OnboardingView` + `OnboardingDelegate` usage.

---

## 1. Minimum platforms raised (action required)

| | 2.0 | 2.1 |
| --- | --- | --- |
| iOS | 16 | **17** |
| macOS | 10.15 | **14** |

Raise your own package/app deployment target to at least iOS 17 (macOS 14) or SPM will refuse
to resolve the dependency.

## 2. New transitive dependencies (action required)

2.1 adds three packages to the dependency graph:

| Package | Version | Why |
| --- | --- | --- |
| `skip` | `1.9.2+` | Build-time transpiler plugin (`skipstone`) |
| `skip-fuse-ui` | `1.0.0+` | Cross-platform SwiftUI runtime bridge |
| `OpenCombine` | `0.15.1+` | Combine replacement on Android |

These resolve automatically. Your `Package.resolved` will pick them up on the next resolve;
commit the updated lockfile. `ConfettiSwiftUI` is now gated to iOS/macOS only and won't be
built for Android.

## 3. The skipstone build plugin (one-time approval)

`Onboarding` and `CoreUI` now declare the `skipstone` package plugin. The first build after
upgrading, Xcode prompts to trust and enable it (or, on the command line, SPM asks to allow the
plugin). Approve it.

- **iOS / macOS builds** transpile nothing — the plugin is effectively a no-op — so you do **not**
  need the Skip toolchain to keep shipping your iOS app.
- **Building for Android** requires the Skip toolchain:

  ```sh
  brew install skiptools/skip/skip
  skip checkup
  ```

  See the [Skip docs](https://skip.tools/docs) for wiring up the Android target.

## 4. Source compatibility

The documented integration surface is unchanged — **no code changes** are needed for the standard
flow:

- `OnboardingView`, the JSON flow, and your `OnboardingDelegate` callbacks work as before.
- `ColorPalette` theming is unchanged.
- The `primaryButtonStyleCompat(colorPalette:)` / `secondaryButtonStyleCompat(colorPalette:)`
  view modifiers keep the same signatures. (Internally `SecondaryButtonStyle` now takes its palette
  as an init parameter instead of reading the environment, but callers are unaffected.)

One internal removal: the `asyncSink(receiveValue:)` `Publisher` convenience was dropped (it relied
on Combine, which isn't available on Android). If you reached into it, replace it with your own
`sink` + `Task`.

## 5. New, optional cross-platform APIs

If you write **custom step views** and want them to render on both platforms, 2.1 makes these
public in `CoreUI`:

- `AdaptiveDivider`, `AdaptiveSymbol` — platform-adaptive primitives (SF Symbols ↔ Android equivalents).
- `UIConstants` — the shared padding/spacing tokens used by built-in steps.
- Reveal/animation modifiers: `revealBottomButton(_:)`, `revealBottomBarButton(_:)`,
  `staggeredAppear(visible:)`, `staggeredReveal(count:revealed:)`, `bottomBar { }`,
  `applyRippleEffect(alignment:)`.

Adopting them is optional; existing custom steps keep working on iOS untouched.

---

## Update your version pin

```swift
.package(url: "https://github.com/VPavelDm/Onboarding-iOS.git", from: "2.1.0")
```
