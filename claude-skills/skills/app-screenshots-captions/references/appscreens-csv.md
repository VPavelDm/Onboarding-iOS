# AppScreens translation CSV — format & rules

AppScreens localizes caption text via a CSV round-trip. What AppScreens tells the user:

> Export your current translations to CSV, update them in a spreadsheet, then import the file
> back. Keep the headers the same and update only the translation rows you want to replace.
> If you move text boxes around after export, update the screenshot or text box numbers in
> the CSV before importing. Supported rich text in TranslationText: `<b>`, `<i>`, `<u>`, text
> color spans, text background color spans, and `<br>`. Other HTML formatting will not be
> preserved. Upload the CSV to review matches first. We only replace translations that are
> present in the file.

## Columns (exact order, exact headers)

```
Screenshot,TextBox,Subtitle,BaseLanguage,BaseText,TranslationLanguage,TranslationText
```

| Column | Meaning | Rule |
|---|---|---|
| `Screenshot` | 1-based slide index | Set by AppScreens; don't invent. Re-export if boxes moved. |
| `TextBox` | 1-based text box within the slide | Same. A slide can have several (headline, sub, bubbles). |
| `Subtitle` | 1 if the box is a subtitle, else 0 | Leave as exported. |
| `BaseLanguage` | source lang code (e.g. `en-US`) | Leave as exported. |
| `BaseText` | the source caption text | **Match key — never edit.** Includes its rich-text tags (`<b>…</b>`, spans). |
| `TranslationLanguage` | target storefront code | One row per (box × language). |
| `TranslationText` | the localized caption | **The only column you write.** |

- **Encoding:** UTF-8 **with BOM**. Read/write with Python `encoding="utf-8-sig"` (AppScreens
  exports a BOM; matching it avoids a mojibake first header cell).
- **Quoting:** standard CSV; fields with commas/quotes/newlines are double-quoted. Use a real
  CSV writer, never string concatenation (captions contain commas and `"`).
- **Row identity:** a translation row is identified by (`Screenshot`, `TextBox`,
  `TranslationLanguage`). `BaseText` is how AppScreens maps a row to a text box's source.

## Matching strategy (why we key on BaseText)

The same headline can appear once per language as separate rows sharing a `BaseText`. Our
scripts look up the caption by **`BaseText`** in `captions.json` and write the right
`TranslationText` for that row's `TranslationLanguage`. This means:
- The copy data (`captions.json`) is keyed by the exact `BaseText` string.
- Renumbering text boxes doesn't break us (we don't rely on `Screenshot`/`TextBox`), but the
  user should still re-export so the numbers AppScreens imports are current.

## Conventions we follow

- **`en-US` mirrors `BaseText`.** The source row's translation equals the base text.
- **Intentionally-English boxes stay English.** E.g. an English-teaching app's sample-phrase
  bubbles: their `BaseText` is `<span …>…</span>` (styled sample), and every locale keeps the
  English. Configure these via `keepEnglishBasePrefixes` in `captions.json`.
- **Rows we have no copy for are left untouched** (their existing `TranslationText` passes
  through). Because AppScreens "only replaces translations present in the file", you can also
  ship a subset CSV containing just the rows you changed.

## Rich text

Only these survive import — emit nothing else:
- `<b>bold</b>`, `<i>italic</i>`, `<u>underline</u>`
- text color: `<span style="color:#RRGGBBAA">…</span>` (AppScreens uses 8-digit hex, e.g.
  `#ffd42eff`; 6-digit also works)
- background color: `<span style="background-color:#RRGGBBAA">…</span>`
- line break: `<br>`

Keep tags balanced and nested simply. A stray `<br/>`, `<p>`, class names, or inline styles
other than `color`/`background-color` will be stripped, silently changing the caption.
