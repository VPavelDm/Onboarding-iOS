---
name: aso
description: Monthly App Store Optimization loop for an iOS app — gather the current situation (keyword ranks via the iTunes Search API, reviews mining, competitor deltas, App Store Connect analytics, PostHog/Amplitude funnel, RevenueCat/Adapty revenue, Search Console web traffic), diff against last month's state, diagnose visibility-vs-conversion, propose ranked improvements, and implement them (per-locale metadata pack, promotional text, review-prompt code). Use this skill whenever the user asks to run ASO, do an App Store audit, improve organic downloads/installs, check keyword rankings, analyze app store performance, optimize store listing/metadata/screenshots, or asks why downloads are flat — for a new app (first run = baseline) or an existing one.
---

# ASO Monthly Loop

Goal: increase organic App Store traffic — and make every run attributable, so next
month's run can say "the subtitle change worked" instead of guessing again. The unit of
work is one app; multi-app users run it once per app.

## Decision policy

Derive everything possible from `aso/config.json`, `aso/state.json`, and live data.
Human gates are exactly two: **public-facing metadata is prepared as a paste-ready pack,
never submitted by you** (the user pastes into App Store Connect and ships it with a
release), and **code changes land as normal reviewed edits** in the app repo. Everything
else — which keywords to track, which competitors matter, what to propose — decide
yourself and show your reasoning. Ask questions only on the first run for an app
(missing config) or when credentials are absent.

## First run for an app (no aso/ directory)

1. Create `aso/config.json` from `assets/config.example.json`: app id, storefronts (from
   the listing's localizations + the user's markets), 10–20 target keywords (run the
   sibling `keyword-research` skill to build and validate the list against live App
   Store data — or, minimally, infer from listing copy, category, competitor subtitles
   and confirm with the user this one time), 3–5 competitor app ids (iTunes search for the head terms), providers
   (analytics: posthog|amplitude|none; monetization: revenuecat|adapty|none; gsc: bool;
   astro: bool).
2. If App Store Connect API access is not configured, offer setup —
   `references/asc-api-setup.md`. The skill degrades gracefully without it (public data
   only), but impressions/conversion analytics are what separate diagnosis from guessing.
3. Run the normal loop below; there's no diff yet — the output IS the baseline.

## Monthly loop

### 1. Gather (read references/gather-signals.md)

Prefer the Astro MCP tools for ranks/ratings when configured and running (they have
tracked history); otherwise run `scripts/keyword_ranks.py` (one-shot rank proxy per
keyword per storefront). Run `scripts/fetch_reviews.py` (recent reviews per storefront
with themes). Snapshot the
listing (name/subtitle/rating/count/version), competitor listings, ASC analytics if
configured (`scripts/asc_client.py`), and the configured providers (PostHog/Amplitude
funnel, RevenueCat/Adapty conversion, GSC clicks to the marketing site). Every source is
optional except the public ones — record in the report which were unavailable.

### 2. Diff against state

Read `aso/state.json`: rank movements per keyword, rating velocity (new ratings/month),
review-theme shifts, competitor changes (renamed? new screenshots? rating surge?), and —
critically — **what actions were taken last run and what happened to their target
metrics**. An action without a visible effect after two cycles gets reconsidered.

### 3. Diagnose (read references/diagnose-and-propose.md)

Split the problem per storefront: **visibility** (low impressions / poor ranks) vs
**conversion** (impressions don't become downloads). Different fixes; don't propose
conversion work for a visibility problem. Localized storefronts fail independently — a
2.5★ FR rating with a healthy US listing is a FR problem, not an app problem.

### 4. Propose

Ranked list, impact ÷ effort, each item tagged with what it requires:
`[now]` editable without release (promotional text, review responses, price) ·
`[release]` needs a version (name, subtitle, keyword field, screenshots, description) ·
`[code]` app changes (review prompt, onboarding) · `[human]` only the user can
(respond to specific reviews, record video, outreach). Cap at 5 items — a monthly loop
that proposes 20 things ships none.

### 5. Implement

- `[now]` items: write the new promotional text etc. into the metadata pack marked
  "paste today, no release needed".
- `[release]` items: produce the per-locale metadata pack from
  `assets/metadata-pack-template.md` — every configured storefront, keyword field
  crafted per the rules in diagnose-and-propose.md.
- `[code]` items: implement directly in the app repo as normal code changes (e.g.
  SKStoreReviewController prompt after a success milestone), following that repo's
  conventions.

### 6. Log + report (read references/state-and-reporting.md)

Update `aso/state.json` (snapshot + actions taken with their target metrics). Write
`aso/reports/YYYY-MM.md`: metrics table with month-over-month deltas, last month's
actions → outcomes, this month's diagnosis, actions taken, the metadata pack location,
and the `[human]` queue. Lead with the one-line verdict ("visibility improving,
conversion flat — this month targets screenshots").

## Quality bar

- Never fabricate metrics: unavailable source → "unavailable", not an estimate.
- Rank proxy is a proxy (iTunes Search API ≈ store order, not exact) — trends matter,
  absolute positions are indicative. Say so in reports.
- One experiment per lever per cycle where possible; simultaneous title+subtitle+keywords
  changes are unattributable.
- Metadata packs respect Apple limits (name 30, subtitle 30, keyword field 100,
  promotional text 170) — count characters, per locale.
