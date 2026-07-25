# Writing captions

The caption is the headline laid over a screenshot in AppScreens. It and the screen beneath
it must sell the **same one idea**. Screen selection/order/demo content is the
`app-screenshots` skill's `shot-story.md`; here we write the *words*.

## Copy principles

- **One headline per slide**, one benefit. The screen is the proof; the caption names the win.
- **≤ ~6 words.** It's read in under a second on a search-results thumbnail.
- **Benefit-first, verb-led.** "Know exactly what to say" > "Smart phrase suggestions".
- **Highlight one value word/phrase** in the accent color — the word the eye should catch
  ("what to **say**", "your **exact level**"). One span per caption; keep it a contiguous
  substring so it localizes cleanly.
- **First three slides stand alone** — most users never swipe past three.
- **No claims you can't back**: no fake ratings, "#1", or endorsements in caption text.

## The story doc

Keep the human-readable plan in `captions/story.md` (see
`assets/caption-story-template.md`): one section per slide with the screen it maps to, the
English headline, and the highlight word. This is what you review with the user before
localizing. Then mirror it into `captions/captions.json` (the machine source the scripts
read).

Example slide row:

| Slide | Screen | Headline (en) | Highlight |
|---|---|---|---|
| 1 Promise | populated home | Know exactly what to say | what to say |
| 2 Plan | goal picker | A plan made just for you | made just for you |
| 3 Mechanic | build-a-phrase | Learn by building, not memorizing | building |

## Mapping to BaseText

Each headline becomes a `BaseText` in AppScreens (usually wrapped `<b>…</b>`). In
`captions.json`, key each caption by its **exact `BaseText`** (including the `<b>` wrapper if
that's what AppScreens exported), so the translate script matches rows precisely. The
highlight substring is applied to the *translated* text later, so it's stored per locale (see
`localizing-captions.md`), not baked into the English headline here.
