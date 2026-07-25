---
name: app-screenshots
description: Produce clean, localized raw App Store screenshots for an iOS app by REBUILDING each screen as a standalone, disposable SwiftUI reproduction (never reusing or importing production views), driving them with a flag-gated screenshot launch mode, seeding deterministic per-locale demo content, and capturing every screen × locale automatically with fastlane snapshot at a clean 9:41 status bar. Use this skill whenever the user wants to make/update App Store (or Play Store) screenshots or app previews, "capture app screens", set up fastlane snapshot, add screenshot localization, or design the screenshot story/order. This skill produces the raw device screens; adding marketing captions/backgrounds/frames on top of them (e.g. in AppScreens) and localizing those captions is the sibling skill `app-screenshots-captions`.
---

# App Store Screenshots

Goal: a folder of upload-ready, per-locale screenshots that sell the app — produced from
**reproduction screens you fully control**, not the live app UI. The unit of work is one
app; multi-app users run it once per app.

## Two rules that never bend

1. **Never modify production code; match the app's UI.** Screenshots must look **identical
   to the real app screens by default** — only deviate when the user asks, per screen. The
   hard invariant is that you never change a production view/view-model to make screenshots
   work. Two allowed ways to get a screen, both from an isolated `Screenshots/` group:
   **(a) reuse the real view** when it accepts injected demo data (a model, a `Binding`, a
   closure) and renders without its own view-model/network — this guarantees identical UI
   and is preferred; **(b) reproduce** the layout in a new view (composing the real *pure*
   subcomponents) when the screen owns its view-model — copy its structure faithfully. Never
   reach into a view-model/service/network or edit app files. See
   `references/rebuilding-views.md`.
2. **You produce files; the user uploads them.** Never submit to App Store Connect. The
   output is `fastlane/screenshots/<locale>/…png`; the user reviews and uploads.

Everything screenshot-related is **additive and flag-gated** (`-ui_screenshots 1` /
`FASTLANE_SNAPSHOT`). The production launch path is untouched; the screenshot root is only
reachable behind the flag.

## Decision policy

Derive everything possible from `screenshots/config.json` (create from
`assets/config.example.json`). Reuse the app's existing localization locale set rather than
inventing one. Ask the user only on the **first run**, and only for what you can't infer:
the **shot story** (which screens, in what order) and **style** (clean device screens vs.
caption/framing layer). Decide the rest and show your reasoning.

## First run for an app (no `screenshots/` dir)

1. **Read the app.** Identify the target, scheme, existing UITest target (create one if
   absent), the design system (colors/fonts), and the locale set (from the app's
   `.xcstrings` / `knownRegions`). Write `screenshots/config.json`.
2. **Agree the story.** Propose 4–6 screens, one idea each, best-first — see
   `references/shot-story.md`. Confirm screens + order + style with the user (this once).
3. **Port the pipeline** (`references/pipeline-setup.md`): copy the four templates from
   `assets/` — `ScreenshotMode`, `ScreenshotRootView`, `ScreenshotUITests`, `Snapfile` —
   into the app, and add the one-line app-entry hook. Fill in the screen enum + routing.
4. **Rebuild the screens** (`references/rebuilding-views.md`): one standalone view per shot,
   seeded with demo state, isolated from app code.
5. **Localize demo content** (`references/demo-content.md`): a `Screenshots.xcstrings` table
   of native-sounding demo strings (names, sample messages, dates) per locale — generated,
   not literally translated.
6. **Capture + verify** (`references/capture-and-verify.md`): `scripts/run_screenshots.sh`,
   then `scripts/check_captures.py`. Do an **English-only pass first** so the user approves
   the look before you fan out all locales.

## Ongoing loop (setup exists)

Add/adjust a screen → seed its demo content → run for the changed screens/locales → verify
the gallery → localize new strings → re-verify. Keep `screenshots/config.json` the source
of truth for screens, devices, and locales.

## Output = raw device screens

This skill's deliverable is clean raw screens in **`fastlane/screenshots-raw/<locale>/…png`**
(`fastlane snapshot`'s native layout — e.g. `en-US/iPhone 17 Pro-01_Home.png`: locale folder,
auto device prefix, your `NN_Name`; see `references/pipeline-setup.md` for why the locale
must be the folder) — kept separate from `fastlane/screenshots/` on purpose: that dir is what `fastlane deliver`
uploads and where finished AppScreens exports live, so raw captures must not land there or
they clobber final assets. The app screen's own header is the hero, zero post-processing.
That's shippable as-is for many apps. If the store listing needs marketing **captions /
backgrounds / device frames** on top
(the common polished look), those are composed downstream — typically in **AppScreens** —
and localized via its CSV flow. That whole stage is the sibling skill
**`app-screenshots-captions`**; hand it these raw PNGs. Don't build a DIY compositor here.

## Quality bar

- **Never edit production views.** Screenshot code is additive/isolated only. A diff that
  touches a real view or view-model is a failure of this skill.
- Apple specs: correct pixel size per device class; no letterboxing; ≤10 per locale.
- No clipped or overflowing **localized** strings — the longest language governs layout;
  verify RTL (ar/he) mirrors correctly. See `capture-and-verify.md`.
- Deterministic: fixed 9:41 / full-battery status bar, seeded content, no live clocks,
  network, or randomness. Bump Dynamic Type for legibility at thumbnail size.
- One idea per shot; first three shots must stand alone (most users never swipe past 3).
- Never fabricate reviews/ratings or imply endorsements in caption text.
