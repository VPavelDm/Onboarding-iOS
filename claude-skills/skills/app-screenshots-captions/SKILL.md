---
name: app-screenshots-captions
description: Write, highlight, and localize the marketing CAPTION text laid over App Store screenshots in AppScreens, and produce the AppScreens translation CSV to import back. Use this skill whenever the user is adding headline/caption text to screenshots, wants to localize screenshot captions into many storefronts, mentions AppScreens, has an AppScreens translations CSV to export/edit/import, wants the value word highlighted in a color span, or asks to translate/transcreate their screenshot marketing copy. This is the downstream companion to `app-screenshots` (which produces the raw device screens); here we handle the caption layer and its localization CSV.
---

# App Store Screenshot Captions (AppScreens)

The user's screenshot pipeline has two stages:
1. **`app-screenshots`** produces clean raw device screens with fastlane, in
   `fastlane/screenshots-raw/`.
2. **AppScreens** (a macOS app) imports those raw screens and lays out marketing **captions**,
   backgrounds, and device frames. AppScreens localizes caption text via a **CSV
   export → edit → import** loop. **This skill owns stage 2's copy + localization.**

We do not automate the AppScreens GUI (arranging text boxes, backgrounds, frames — the user
does that). We own everything text: the caption **story + copy**, the **highlight** spans,
the **per-locale translations**, and the **exact import CSV** AppScreens expects.

## The loop

1. **Story + English copy.** One benefit-led headline per slide, aligned with the screen it
   sits on. See `references/writing-captions.md`; keep it in `captions/story.md` +
   `captions/captions.json`.
2. **User exports** the current translations CSV from AppScreens (File → export) to
   `captions/appscreens-export.csv`. `BaseText` is the match key.
3. **Localize** — fill `captions.json` translations + highlight substrings for every
   storefront (`references/localizing-captions.md`; generate with a native-reviewer fan-out).
4. **Build the import CSV**:
   ```sh
   scripts/translate_captions_csv.py --export captions/appscreens-export.csv \
       --data captions/captions.json --out captions/appscreens-import.csv
   scripts/highlight_captions_csv.py --in captions/appscreens-import.csv \
       --data captions/captions.json --out captions/appscreens-import.csv
   scripts/check_captions_csv.py --export captions/appscreens-export.csv \
       --import captions/appscreens-import.csv        # validate before importing
   ```
5. **User imports** `appscreens-import.csv` back into AppScreens ("Upload the CSV to review
   matches first" — AppScreens only replaces rows present in the file), reviews, applies.

## AppScreens CSV contract (do not break)

Columns, verbatim, in order: `Screenshot, TextBox, Subtitle, BaseLanguage, BaseText,
TranslationLanguage, TranslationText`. Full rules in `references/appscreens-csv.md`. The
essentials:
- **Keep the headers identical.** Keep encoding UTF-8 **with BOM** (`utf-8-sig`).
- **Never edit `BaseText`** — it is the lookup key AppScreens matches on. Only write
  `TranslationText`.
- **Only rows present in the file are replaced.** You may ship a subset; untouched rows keep
  their AppScreens value.
- If text boxes were moved/renumbered in AppScreens, the user re-exports first so
  `Screenshot`/`TextBox` numbers are current — don't hand-edit numbers.
- **Rich text allowed in `TranslationText`:** `<b>`, `<i>`, `<u>`, text-color spans,
  background-color spans, `<br>`. Anything else is dropped on import — never emit other tags.

## Decision policy

Derive from `captions/captions.json` (the source of truth for copy + highlights) and the
user's export CSV. Human gates: the user runs AppScreens' export/import and does the visual
layout; you produce copy + CSV, never touch the GUI or submit anything. Ask on first run
only for the slide **story/copy intent** if it isn't already decided in `app-screenshots`.

## Quality bar

- Caption ≤ ~6 words, benefit-first, one idea; it must reinforce the screen beneath it.
- The highlight substring MUST be an exact substring of that locale's translated caption —
  `highlight_captions_csv.py` warns on every miss; resolve all misses before importing.
- Transcreate, don't translate literally; keep intentionally-English text English (e.g. an
  English-teaching app's sample phrases). `en-US` `TranslationText` mirrors `BaseText`.
- Balanced tags, whitelist-only rich text, no empty target translations, no `BaseText`
  accidentally left in a non-English `TranslationText`. `check_captions_csv.py` enforces this.
- Respect each caption's on-image width — the longest language governs; rework, don't clip.
