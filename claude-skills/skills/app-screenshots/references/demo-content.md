# Localized demo content

Demo content is what makes screenshots feel real and native. It lives in a dedicated string
catalog — **table `Screenshots`** — separate from the app's `Localizable`, so it ships only
with screenshot builds conceptually and never pollutes the app's real strings.

## Structure

`Screenshots.xcstrings` (sourceLanguage = the app's dev language). Keys are stable
identifiers, NOT English sentences (unlike the onboarding-key pattern), because
`ScreenshotMode` looks them up explicitly:

```swift
static var greetingName: String { String(localized: "greeting_name", table: "Screenshots") }
static var heroMessage: String  { String(localized: "hero_message",  table: "Screenshots") }
```

Group keys per screen: `home_*`, `compose_*`, `detail_*`, seeded lists as
`library_1…n` / `capsule_1…n`. See `assets/Screenshots.xcstrings.example`.

## Write for the screenshot, not the app

- **Shorter than real content** — enlarged screenshot type overflows real-length copy. Craft
  chips/titles to fit at `.xxLarge`.
- **Flattering and concrete** — a specific, warm sample beats lorem ipsum ("For my 30th
  birthday 🎂" > "Sample capsule 1").
- **Emotionally on-message** — the demo line is marketing copy; make it land.

## Native, not translated

Generate per-locale demo content that a native speaker would actually see — this is
**transcreation**, not literal translation:

- **Names** → a natural local name per storefront (Anna → Анна → さくら → 민준 → أحمد → Sofia).
- **Sample messages/affirmations** → idiomatic in the target language, same emotional beat,
  not word-for-word.
- **Dates / numbers** → phrased naturally; prefer letting the app format dates from a seeded
  `Date` so the OS localizes them, rather than hard-coding a date string.
- **Length** → each language must fit the same layout; rework, don't truncate.
- **RTL (ar, he)** → the reproduction view must lay out correctly mirrored; keep leading
  emoji/punctuation on the correct side.

### Generating it at scale
Reuse the localization fan-out: one native-reviewer subagent per language group, given the
English demo keys + this brief, returning `{ locale: { key: value } }`, then assemble into
`Screenshots.xcstrings`. (Same approach the app's `Localizable`/`Onboarding` localization
used.) Always do an **English pass first** and get the shots approved before fanning out —
translating demo content for a story that then changes is wasted work.

## Locale set

Match the app's shipping locales, mapped to App Store storefront codes (see the caveat in
`pipeline-setup.md`). Only include a locale in the `Snapfile` once its demo content exists;
a missing key falls back to the source language and silently ships an English screenshot in
a non-English storefront — `check_captures.py` flags likely fallbacks.
