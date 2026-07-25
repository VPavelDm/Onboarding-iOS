# Gather Signals

Collect everything below that's available; note what isn't. All public sources need no
credentials.

## Public (always available)

- **Listing snapshot** — iTunes Lookup API per storefront
  (`https://itunes.apple.com/lookup?id=<id>&country=<cc>`): name, subtitle (often null —
  scrape the web listing with a browser UA if needed), rating, ratingCount, version,
  release date, price/IAP. Snapshot per configured storefront — ratings and even metadata
  differ per country.
- **Keyword ranks** — `scripts/keyword_ranks.py`. The iTunes Search API returns results
  in near-store-search order; the app's position for a term is a free rank proxy. Track
  the configured keywords across configured storefronts; the script outputs JSON for the
  state file. Trends >> absolute numbers.
- **Reviews** — `scripts/fetch_reviews.py` (public RSS feed, per storefront). Mine for:
  recurring complaints (conversion killers + roadmap), feature requests, and the exact
  vocabulary users use (feeds the keyword field — users' words beat marketing words).
  Rating velocity = new ratings since last run; a low count is usually THE bottleneck
  for small apps.
- **Competitors** — lookup each configured competitor id: name/subtitle changes (they do
  ASO too — their new subtitle keywords are intelligence), rating count growth vs yours,
  screenshot changes (check the web listing). Also run 2–3 head-term searches and note
  who NOW ranks above the app that didn't before.

## App Store Connect (if configured — references/asc-api-setup.md)

Via `scripts/asc_client.py`. The metrics that matter monthly:
- Impressions and product page views (visibility)
- Conversion rate = units / impressions (conversion health) — segment by source type:
  App Store Search vs Browse vs Referrer
- App Store Search terms driving downloads (ground truth that keyword work is landing)
Downloadable analytics reports are asynchronous (request → poll → download) — the client
handles the dance; don't hand-roll it inline.

## Configured providers (per aso/config.json)

- **PostHog** (`analytics: "posthog"`): use the PostHog MCP tools — monthly funnel from
  first-open through activation; a store fixing traffic into a leaky onboarding is wasted.
- **Amplitude** (`analytics: "amplitude"`): Dashboard REST API with
  `AMPLITUDE_API_KEY`/`AMPLITUDE_SECRET_KEY` env vars; query the equivalent funnel. If
  keys are absent, ask the user for the two monthly numbers (first-opens, activated).
- **RevenueCat** (`monetization: "revenuecat"`): MCP tools — overview metrics, trial
  starts, trial→paid conversion, MRR delta.
- **Adapty** (`monetization: "adapty"`): REST API with `ADAPTY_API_KEY`; same three
  numbers. Absent key → ask.
- **GSC** (`gsc: true`, for apps with a marketing site): clicks/impressions for the site
  + store outclicks if measurable. Simplest reliable path: ask the user to export the
  performance CSV, or read it via the API if a service account is configured.
- **Astro** (`astro: true`): the Astro macOS ASO app exposes a local MCP server
  (`http://127.0.0.1:8089/mcp`, no auth; requires the app running with MCP enabled in
  its Settings — register once: `claude mcp add --transport http --scope user astro
  http://127.0.0.1:8089/mcp`). Its tools include `search_rankings` (WITH history),
  `get_app_ratings` (per store/country, with history), `get_app_keywords`,
  `extract_competitors_keywords` (NLP over competitor metadata), `get_keyword_suggestions`,
  and `search_app_store`. **When Astro is available it is the preferred rank/ratings
  source** — real tracked history beats the one-shot iTunes proxy; use
  `scripts/keyword_ranks.py` as the fallback when Astro isn't running. During the propose
  phase, `extract_competitors_keywords` + `get_keyword_suggestions` are direct inputs to
  keyword-field work, and `add_keywords` can push this run's new targets into Astro so
  next month has history for them (it also batch-fetches rank/popularity/difficulty on
  add, ≤100 per call). `remove_keywords` exists but is destructive — list what would be
  deleted and get explicit user confirmation first. Rate limit: 60 req/min.

## Output of this phase

One `gather` object (the state-file schema in state-and-reporting.md): listing snapshots,
rank table, review themes + velocity, competitor notes, analytics numbers (or
"unavailable"), provider numbers. Everything downstream reads only this object.
