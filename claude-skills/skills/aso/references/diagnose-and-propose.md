# Diagnose & Propose

## The two-problem split

Compute per storefront (each fails independently):

- **Visibility problem** — impressions low or falling; ranks poor for target keywords.
  Fixes: keyword field, title/subtitle keywords, localization coverage, rating COUNT
  (search rank correlates with rating volume), in-app events, category choice.
- **Conversion problem** — impressions healthy, downloads lag (conversion < ~2–3% from
  search is weak; >5% is good, but compare to own history, not folklore).
  Fixes: first three screenshots (most users see nothing else), rating VALUE, subtitle
  as value proposition, promotional text, price/trial framing, review responses.

Without ASC analytics, infer: ranks good + downloads flat → conversion; ranks poor →
visibility. Say the inference is indirect.

## Prioritization heuristics (small apps, roughly in order)

1. **Rating count under ~100 is almost always the binding constraint** — it suppresses
   both rank and conversion. The `[code]` fix (review prompt after a success moment)
   usually beats any metadata work. Check it's not already implemented before proposing.
2. **A broken localized storefront** (bad rating, untranslated/grammatically wrong copy)
   in a configured market — targeted, high-leverage fix.
3. **Keyword field hygiene** (see below) — cheap, ships with any release.
4. **Subtitle** — 30 chars of both ranking signal and value prop; empty subtitle = free
   real estate.
5. **Screenshots 1–3** — biggest conversion lever, highest production effort. Propose
   with a concrete storyboard (which feature, which caption), not "improve screenshots".
6. Everything else (description rewrite, in-app events, PPO A/B tests) after the above.

## Keyword field rules (100 chars, per locale)

- Comma-separated, **no spaces after commas**, no plurals AND singulars (Apple stems),
  no words already in the app name or subtitle (indexed already — duplicates waste chars).
- Use users' vocabulary from reviews mining; single words beat phrases (Apple combines).
- Don't burn chars on: the category name alone ("education"), competitor brand names
  (rejection risk), "app", "free", "iphone" (ignored/implied).
- Localization cross-pollination: keywords in one locale index in related storefronts
  (e.g. en-GB + en-US, or the infamous es-MX for US Spanish) — use secondary locales to
  effectively widen the 100-char budget for a storefront.

## Title / subtitle

- Weight: name > subtitle > keyword field. `Brand: top keyword phrase` is the standard
  name pattern (30 chars).
- Subtitle = highest-value keywords that also read as a benefit. Never keyword soup —
  it's the most-read line of the listing.
- Rebrand caution: name changes reset brand-search equity; keep the old key phrase in
  the name/subtitle during transitions.

## What requires what (tag every proposal)

| Change | Tag |
|---|---|
| Promotional text (170 chars), review responses, price | `[now]` |
| Name, subtitle, keyword field, screenshots, description | `[release]` |
| Review prompt, onboarding fixes, in-app events code | `[code]` |
| Reply strategy to specific reviews, video, outreach | `[human]` |

## Attribution discipline

One lever per cycle where feasible. If multiple `[release]` items ship together (common —
releases are scarce), record the bundle in state and treat next month's readout as
bundle-level. Never claim single-change attribution for a bundled release.
