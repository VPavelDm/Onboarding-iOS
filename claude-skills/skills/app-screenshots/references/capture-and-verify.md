# Capture and verify

## Run

```sh
scripts/run_screenshots.sh            # reads screenshots/config.json, runs fastlane snapshot
# under the hood: cd <app>; bundle exec fastlane snapshot
```

Prerequisites (one-time per app):
- `bundle exec fastlane snapshot init` → drops `SnapshotHelper.swift` into the UITest target
  and a starter `Snapfile` (replace it with `assets/Snapfile.template`, filled in).
- The UITest target builds and the scheme is shared (`xcodebuild -list` shows it).
- Simulators for the configured devices are installed.

Iterate fast during design with **one screen, one language**:
```sh
scripts/run_screenshots.sh --languages en-US --screens home
```

### `simctl` fallback (no UITest target yet)
`fastlane snapshot` requires a UITest target. If the app doesn't have one yet and you just
want to see the shots, capture with `simctl` against a booted sim: `install` the app, override
the status bar, then per screen `launch` it with `-ui_screenshots 1 -screenshot_screen <name>`
and `io booted screenshot`. Two gotchas:
- **"◀ Return to <app>" breadcrumb.** The first `launch` shows a return-to-previous-app chip
  in the status bar (whatever app was foreground before). **Fix:** do one throwaway warm-up
  `launch` of your app *before* the capture loop, so your app is the most-recent app and no
  cross-app chip appears. (Overriding the status bar does NOT remove this chip.)
- **Language:** pass `-AppleLanguages "(<code>)" -AppleLocale <code>` as launch args per
  locale. Set the same status-bar override args as the Snapfile.

This is a fallback for previewing; the proper multi-locale, clean-status-bar path is the
UITest target + `fastlane snapshot`, which never shows the breadcrumb.

## Verify

```sh
scripts/check_captures.py             # completeness + sanity over the output dir
```
It compares each locale against the reference (en-US) **by filename**, so the basename must
be identical across locale folders — which `snapshot`'s `<locale>/<device>-<name>.png` naming
gives you for free. A per-locale suffix (`…-01_Home_de-DE.png`) makes every shot read as
MISSING/EXTRA and silences the cross-locale checks; drop it. It reports:
- **Missing** — any `screen × locale` PNG absent.
- **Wrong size** — dimensions not matching the device class Apple expects.
- **Likely English fallback** — a non-English screenshot whose text pixels match `en-US`
  (heuristic: identical file hash or near-identical byte size to the en-US shot) → a demo
  string wasn't translated.
- **Suspicious blanks** — near-uniform images (crash/black screen/loading state captured).

Then open the fastlane-generated gallery to eyeball everything at once:
```sh
open fastlane/screenshots-raw/screenshots.html
```
(Raw screens live in `fastlane/screenshots-raw/`. Do **not** use `fastlane/screenshots/` —
that's `deliver`'s upload dir and where finished AppScreens exports live; capturing into it
clobbers final assets.)
(That HTML is fastlane's auto-generated **preview contact-sheet** — a grid of all shots by
language/screen with a lightbox. It is NOT part of the uploaded assets and adds no captions
to the images.)

## What to look for by eye

- **Clipping / overflow** — the longest language (usually de, ru, or a CJK line-break)
  governs layout. Fix by reworking the demo string or the reproduction view, never by
  truncating.
- **RTL correctness** — ar/he mirror: leading icons, chevrons, text alignment, and the
  status bar all flip; check nothing is stranded on the wrong side.
- **Matches the app** — every section of the real screen is present (header, hero, list,
  filter/tab bars, nav buttons), same order and chrome. A missing section = a reproduction
  bug, not a "cleaner" shot (see `rebuilding-views.md`).
- **Status bar** — uniform 9:41, full battery (white, not charging-green), full signal, and
  **no "◀ Return to <app>" breadcrumb** (a `simctl` artifact — see the fallback note above).
- **Dark/light** — every locale renders the intended appearance (pin it in
  `ScreenshotRootView`); a stray system-styled subview shouldn't invert.
- **Motion artifacts** — no half-faded animation frame, spinner, or skeleton; freeze
  animated UI in the reproduction view.
- **Real content, not placeholders** — no debug badges, `Lorem`, `Sample 1`, or the dev's
  own name leaking through.

## Ship — or hand off to captions

The deliverable is the raw `fastlane/screenshots-raw/<locale>/…png`. Two paths:

- **Clean shots are the final assets** → copy them into `fastlane/screenshots/` (deliver's
  dir) and the user uploads in App Store Connect (this skill never submits; `fastlane
  deliver` is the user's call with their credentials).
- **Captions/backgrounds/frames wanted** → hand these raw PNGs to the **AppScreens** stage,
  covered by the sibling skill **`app-screenshots-captions`** (import screens → add caption
  text boxes/background → export captions to CSV → localize → re-import). Don't composite
  captions here.
