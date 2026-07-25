---
name: keyword-research
description: App Store keyword research and metadata creation for an iOS app — build a 40–60 candidate keyword universe, validate demand via live App Store autocomplete and competition via the iTunes Search API, then craft paste-ready title (30 chars), subtitle (30 chars), and keyword field (100 chars) options. Use this skill whenever the user wants to find or research app store keywords, pick an app name/title/subtitle, write or rewrite the keyword field, prepare launch metadata for a new app, improve organic growth through search, or overhaul listing metadata. For the recurring measure→diagnose→improve cycle on an existing listing, use the sibling `aso` skill instead — but when that loop needs target keywords chosen, this is where they come from.
---

# App Store Keyword Research

Goal: a validated keyword set and paste-ready metadata (title / subtitle / keyword
field) per storefront — grounded in live App Store data, not vibes. Every keyword the
metadata targets should have evidence attached: does anyone search it, and can this
app realistically rank for it?

The crafting rules (char limits, no-duplicate-words, keyword field hygiene,
localization cross-pollination) live in `../aso/references/diagnose-and-propose.md` —
read the "Keyword field rules" and "Title / subtitle" sections before Step 4.

## Step 1 — Context

Derive as much as possible before asking anything: the app's purpose and features from
the repo (CLAUDE.md, README, App Store metadata files); the current listing if the app
is live (iTunes lookup by app id, or search for the brand name); competitors' titles
and subtitles (their full names show up in autocomplete hints and search results — free
competitive intel). Ask the user only what can't be derived: target storefronts, and
any brand constraints on the name.

## Step 2 — Keyword universe (40–60 candidates)

Brainstorm across five buckets — the buckets matter because each reflects a different
search intent, and a listing that only covers one bucket leaves demand on the table:

1. **Direct intent** — what someone types when they want exactly this app
2. **Feature-based** — the app's capabilities as search terms
3. **Emotional / job-to-be-done** — the problem or feeling, not the product category
4. **Competitor-adjacent** — terms users of similar apps would search (the concepts,
   never competitor brand names — those risk rejection and rank poorly anyway)
5. **Long-tail** — 2–4 word phrases with clear intent and low competition

Grow the list with real user queries: run
`scripts/keyword_research.py suggest "<seed>" --country <cc>` on the strongest seeds —
autocomplete hints ARE what people type, and they often surface phrasings you wouldn't
invent (and competitor titles, which reveal what keywords *they* target). With Astro
available (see Step 3), also feed the universe from `get_keyword_suggestions` — it
works for ANY app id, tracked or not, so run it on the top competitors too, and it
returns candidates pre-scored with popularity/difficulty/app count. Once the first
batch of candidates is tracked, `extract_competitors_keywords` (NLP over the apps
ranking for a tracked keyword) mines what competitors target — it requires the seed
keyword to be already tracked, so it runs after Step 3's first `add_keywords` call.

## Step 3 — Validate with live data

**Preferred source — Astro MCP.** The Astro macOS ASO app exposes a local MCP server
(`http://127.0.0.1:8089/mcp`, no auth; requires the app running with MCP enabled in
its Settings — register once:
`claude mcp add --transport http --scope user astro http://127.0.0.1:8089/mcp`).
Check for its tools via ToolSearch before falling back. Rate limit: 60 req/min.
Astro gives real **popularity and difficulty scores** — strictly better than the
proxies below. The flow:

1. Ensure the app is tracked: `list_apps`; if missing, `add_app` with the numeric
   App Store id (find it via `search_app_store`). App not published yet? `add_app`
   with `temporary: true` — research works fine pre-launch.
2. `add_keywords` with the full candidate list (≤100 per call, per store) — **adding
   is validating**: Astro fetches rank, popularity, and difficulty for the whole
   batch. Read the scores back with `get_app_keywords` or `search_rankings`.
3. Sanity-check finalists with `search_app_store` (pass the app's `appId` to see its
   own position): who actually ranks, and are they beatable?
4. Keep the Astro workspace clean, it's the user's daily tool: create a tag for this
   run (`manage_tag`, then `set_keyword_tag`) and record scoring rationale on keepers
   with `set_keyword_note`. After selection, offer to prune discarded candidates via
   `remove_keywords` — destructive: list them and get explicit user confirmation
   first, never prune silently.

**Fallback — bundled script** (public endpoints, works anywhere):

```
python3 scripts/keyword_research.py research candidates.txt --country us
```

Per keyword it returns two proxies (run per target storefront; ~5 min per 40 keywords —
the endpoints rate-limit, the script paces itself):

- **Demand**: does the exact term appear in App Store autocomplete? Suggestions are
  demand-ranked, so exact-match presence ≈ real search volume; absence ≈ thin demand.
- **Competition**: median rating count of the top-10 results. A median in the
  single digits or low hundreds means a small app can crack the top 10; a median in
  the tens of thousands means it can't — say so and discard the term, however
  attractive it looks.

Never fabricate volume numbers. Whichever source you used, name it in the report —
Astro scores are measurements, the script's are proxies.

## Step 4 — Select and craft

Score each validated keyword: relevance to the app (1–5, your judgment), demand
(autocomplete presence), competition (top-10 rating mass). Select for high relevance +
confirmed demand + beatable competition. Show the scoring table including discarded
head terms with the reason ("median 40k ratings in top 10 — unrankable for us").

Then craft, following the rules in `../aso/references/diagnose-and-propose.md`:

- **Title** (≤30 chars): `Brand: strongest key phrase` — 3 options with char counts.
  If the app is live, weigh rebrand cost: name changes reset brand-search equity.
- **Subtitle** (≤30 chars): next-strongest keywords that still read as a benefit —
  it's the most-read line of the listing, never keyword soup. 3 options.
- **Keyword field** (≤100 chars): comma-separated, no spaces after commas, no word
  that already appears in the chosen title/subtitle, singulars only, skip
  "app"/"free"/category names. Show the exact char count.
- For each title+subtitle+keywords combination, list the search phrases it can rank
  for — Apple combines words across all three fields, and this list is what makes the
  no-duplicates rule concrete rather than pedantic.

## Step 5 — Deliver

- A short report: scoring table, chosen set, the options with char counts, rankable
  phrases, and which 3–5 keywords to track.
- If the user runs the monthly `aso` loop: write the chosen keywords into
  `aso/config.json` `target_keywords` and produce the per-locale pack from
  `../aso/assets/metadata-pack-template.md` so the next loop run measures the change.
  With Astro connected the finalists are already tracked from Step 3 (history starts
  accumulating from today) — tag them (e.g. `target`) so they're distinguishable from
  research leftovers, and prune the discards (with confirmation) so the workspace
  reflects the decision.
- Metadata is prepared paste-ready, never submitted — the user pastes into App Store
  Connect and ships it with a release.
- Multi-storefront: repeat Steps 3–4 per locale (translate candidates, don't just
  translate the winners — demand differs per market), and use the localization
  cross-pollination trick from the rules reference to widen the keyword budget.
