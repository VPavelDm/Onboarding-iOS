# Localizing captions

Caption copy is marketing, so **transcreate** — reproduce the punch and rhythm in the target
language, not the literal words. This mirrors the app-localization workflow, but for headline
copy that must fit on an image.

## What goes where

Everything lives in `captions/captions.json` — the source both scripts read:

```json
{
  "highlightColor": "#ffd42eff",
  "keepEnglishBasePrefixes": ["<span"],
  "captions": {
    "<b>Know exactly what to say</b>": {
      "translations": {
        "de": "Wisse genau, was du sagst",
        "ru": "Знай, что именно сказать",
        "ja": "何と言えばいいかがわかる"
      },
      "highlight": {
        "en-US": "what to say",
        "de": "was du sagst",
        "ru": "что именно сказать",
        "ja": "何と言えばいいか"
      }
    }
  }
}
```

- **key** = the exact `BaseText` from the AppScreens export (with its `<b>` wrapper).
- **translations[locale]** = the plain localized headline (no tags). The translate script
  re-applies the outer `<b>/<i>/<u>` wrapper from `BaseText`.
- **highlight[locale]** = the exact substring of *that locale's translation* to wrap in the
  accent color. It MUST appear verbatim in the translation, or the highlight step warns and
  skips it.

## Rules

- **`en-US` mirrors the base** — the translate script sets `TranslationText = BaseText` for
  the source language; no entry needed in `translations`.
- **Keep intentionally-English boxes English** via `keepEnglishBasePrefixes` (e.g. `"<span"`
  for styled sample bubbles an English-teaching app shows verbatim in every storefront).
- **Length fits the image** — the caption sits in a fixed text box; the longest language
  governs. Rework wording to fit; never truncate. Test with the on-image width in mind (de,
  ru, and wrapped CJK are the usual overflowers).
- **Storefront codes** — match the codes AppScreens exported in `TranslationLanguage`
  (`es`, `es-MX`, `pt`, `pt-BR`, `zh-CN`/`zh-Hans`, `zh-TW`/`zh-Hant`, `ar`, …). Use whatever
  the export uses; don't remap.
- **RTL** (ar/he) — the words are fine as plain text; visual mirroring is AppScreens' layout,
  not the CSV's job. Ensure the highlight substring doesn't split a word awkwardly.

## Generating it at scale (fan-out)

For many storefronts, generate `translations` + `highlight` with a **native-reviewer
subagent per language group** (same pattern the app localization used):

- Give each reviewer the English headlines + this brief + the accent word to highlight in
  English.
- Require, per caption per locale: (a) the transcreated headline, and (b) the **exact
  substring** of *their* headline that corresponds to the highlighted English word — returned
  as a substring that literally occurs in (a).
- Assemble into `captions.json`, run the two scripts, then `check_captions_csv.py`. Any
  highlight miss = a reviewer returned a substring that isn't in their translation; send it
  back or fix by hand.

Do the **English pass first** and get the story approved before fanning out — re-localizing a
headline that then changes is wasted work.
