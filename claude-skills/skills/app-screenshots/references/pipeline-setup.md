# Pipeline setup (port into any app)

Five parts. Four are near-verbatim templates in `assets/`; the fifth is a one-line hook.

## 1. `ScreenshotMode.swift`  (from `assets/ScreenshotMode.swift.template`)

Owns: the enable flag, the `Screen` enum, and **localized demo-content accessors** (each is
`String(localized:table:"Screenshots")` so it resolves in the language fastlane launches).

- `isEnabled` — true when `FASTLANE_SNAPSHOT` or `ui_screenshots` default is set.
- `screen` — parsed from `-screenshot_screen <name>`, defaulting to the first screen.
- One accessor per demo string (`greetingName`, `heroMessage`, `demoCapsules`, …). Arrays
  for seeded lists. Keep these compact — screenshot copy is shorter than real content.

## 2. `ScreenshotRootView.swift`  (from `assets/ScreenshotRootView.swift.template`)

Routes `ScreenshotMode.screen` → the right reproduction view. Sets global screenshot-only
modifiers here (`.preferredColorScheme`, `.dynamicTypeSize`). This is the ONLY view gated by
the flag.

## 3. App-entry hook (one line)

In the `@main` App's root:

```swift
var body: some Scene {
    WindowGroup {
        if ScreenshotMode.isEnabled {
            ScreenshotRootView()
        } else {
            RootView()          // the real app, unchanged
        }
    }
}
```

That is the entire production-code footprint. Nothing else in the app changes.

## 4. `ScreenshotUITests.swift`  (from `assets/ScreenshotUITests.swift.template`)

Add to a UITest target (create one if the app has none: new *UI Testing Bundle* target).
The test **taps nothing** — it relaunches the app once per screen with
`-screenshot_screen <name>`, waits for first content, and calls `snapshot(name)`. Label taps
break in non-English locales; screen selection via launch arg does not.

```swift
setupSnapshot(app, waitForAnimations: false)   // false: animated UIs never settle
baseArguments = app.launchArguments
capture(screen: "home",    named: "01_Home")
capture(screen: "compose", named: "02_Compose")
// …
```

Add `import <AppUITests>` snapshot helper: fastlane's `snapshot init` drops
`SnapshotHelper.swift` into the UITest target once (`bundle exec fastlane snapshot init`).

### Output filename convention
`snapshot(name)` writes to `<output_dir>/<locale>/<device>-<name>.png` — e.g.
`snapshot("01_Home")` on iPhone 17 Pro in German →
`fastlane/screenshots-raw/de-DE/iPhone 17 Pro-01_Home.png`. Two invariants this encodes,
both load-bearing for `fastlane deliver`:
- **The first path segment is the locale** — `deliver` reads the storefront from the folder
  name and the device class from the image's pixel size, *not* from the filename. A
  device-first layout (`iphone/en_01.png`) has no locale folder and will not upload. Never
  invert this.
- **The device prefix is auto-added and harmless** — you don't choose it and don't need to
  strip it; keep it. Only the `<name>` you pass is yours: use an `NN_Name` prefix (`01_Home`,
  `02_Compose`) so shots sort into store order, and keep that name **identical across every
  locale** (the folder already carries the locale — don't repeat it in the filename). Same
  basename per locale is also what `scripts/check_captures.py` compares on; a per-locale
  suffix like `01_Home_de-DE.png` still uploads but blinds the checker's fallback/size/blank
  cross-locale heuristics.

If a shot needs a real modal that can't be a standalone root (rare), present it from a
minimal host and wait on a **locale-independent** anchor (e.g.
`app.navigationBars.element(boundBy: 1)`), never a localized label.

## 5. `Snapfile`  (from `assets/Snapfile.template`)

Devices + languages + the UITest scheme + status-bar override:

```ruby
devices(["iPhone 17 Pro"])            # add iPad / more iPhone sizes as needed
languages([...])                       # see the locale-code caveat below
scheme("<AppUITests>")
only_testing(["<AppUITests>/ScreenshotUITests"])
output_directory("./fastlane/screenshots")
override_status_bar(true)
override_status_bar_arguments("--time 9:41 --dataNetwork wifi --wifiMode active --wifiBars 3 --cellularMode active --cellularBars 4 --batteryState discharging --batteryLevel 100")
concurrent_simulators(false)          # deterministic ordering
clear_previous_screenshots(false)     # true to wipe each run
```

### Locale-code caveat (important)
`fastlane deliver`/snapshot uses **App Store storefront codes**, which differ from the app's
own `.xcstrings`/`knownRegions` codes:
- `zh-Hans` (App Store) ↔ `zh-CN` (app) ; `zh-Hant` ↔ `zh-TW`
- `pt-PT` (App Store) — the app may use plain `pt`
- `es` covers both `es` and `es-MX` on the store; `en-US` maps to app `en`/`en-US`
The **simulator language** fastlane sets uses the store code; the app resolves it to its
nearest `.lproj`/catalog language. Record the mapping in `config.json` (`localeMap`) if the
codes diverge, and confirm each store code resolves to a real translation (not English
fallback) during verify.

## Adding a screen later
1. New `case` in `ScreenshotMode.Screen` + branch in `ScreenshotRootView`.
2. New `ScreenshotXView.swift` (isolated reproduction).
3. New demo keys in `Screenshots.xcstrings`.
4. New `capture(screen:named:)` line in the UITest.
5. Add the screen name to `config.json`.
