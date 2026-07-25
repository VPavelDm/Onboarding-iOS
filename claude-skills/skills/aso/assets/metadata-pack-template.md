# Metadata Pack — {App} — {YYYY-MM}

Paste into App Store Connect. Items under "No release needed" apply immediately; the
rest go on the next version and ship with its review. Character counts are per Apple's
limits — verify after pasting (ASC counts some characters differently, e.g. &).

## No release needed — paste today

### Promotional text (≤170 chars, per locale)
**en-US** ({n} chars):
> {text}

## Next release — per locale

### en-US
| Field | Limit | Value | Chars |
|---|---|---|---|
| Name | 30 | {value} | {n} |
| Subtitle | 30 | {value} | {n} |
| Keywords | 100 | {comma,separated,no,spaces} | {n} |

Description: {unchanged / see below}

### de-DE
(same table; write German that a native would — grammar errors in store copy are
conversion killers)

## Screenshot changes (if proposed)
Storyboard per slot: which feature, which caption, which existing asset or what to
capture. Screenshots upload per device size on the version page.

## Rationale
One line per changed field: which diagnosis it addresses and the metric it should move
(mirrors state.json actions[].target_metric).
