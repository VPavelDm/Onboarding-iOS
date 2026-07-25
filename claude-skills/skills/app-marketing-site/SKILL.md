---
name: app-marketing-site
description: Build and deploy a complete SEO + LLM-optimised static marketing website for an app or product — ingest the App Store / Play Store listing, do SERP-grounded keyword research, generate a high-converting landing page plus topic-cluster guide articles, add the GEO layer (llms.txt, AI-crawler robots, JSON-LD), set up scheduled drip-publishing of queued articles, deploy to hosting (AWS S3+CloudFront or alternatives), and wire up Google Search Console + Bing indexing. Use this skill whenever the user wants a marketing site, landing page, "SEO website", app promo pages, guide/blog content for their app, or asks how to make their app rank in Google or get recommended by ChatGPT/LLMs — even if they only mention one piece (e.g. "make a landing page" or "do keyword research for my app").
---

# App Marketing Site

Build a static marketing site that actually earns downloads: real answers to real search
queries, with the app woven in as the way to act on them. The output is a deployed site +
a publishing pipeline, not just HTML files.

## Decision policy (read first)

Decide almost everything yourself; the value of this skill is autonomy. The split:

**Derive, never ask** — brand name, domain (if the app has NO purchased domain, the
fallback convention is a subdomain of lyncil.com: `<brand>.lyncil.com`, e.g.
here.lyncil.com, hutarka.lyncil.com — the Route 53 zone and deploy recipe exist, see
deploy-hosting.md), design language, keyword targets, page
structure, guide topics, image handling, cache headers, structured data. Sources: the
store listing, the project's code/localizations, existing DNS and hosting (`dig`,
`aws route53`/`aws s3`/`aws cloudfront`, `curl -sI` the domain). If the listing name and
the project disagree (e.g. a recent rebrand visible in localized strings or commits),
surface the discrepancy with evidence and use the newer name — don't silently pick one.
Rule of thumb: ask only when the answer is in the user's head, not in their infrastructure.

**Ask upfront, ONE batched question round** (AskUserQuestion, before writing anything):
1. Hosting target — deploy to existing infra found during recon, or set up new? Which?
2. Anything ambiguous discovered on the domain/bucket (see the pre-deploy safety checklist
   in `references/deploy-hosting.md`) — only if investigation left real ambiguity.
3. Publishing cadence + whether to install a scheduler on this machine (persistent change).

**Confirm at the moment, not upfront** — the first production deploy, DNS record changes,
anything costing money or touching an external account. Subsequent deploys are routine.

Mid-flow questions kill the skill's value. If a new question arises mid-build, prefer an
assumption + a note in the final summary over an interruption.

## Workflow

Work through the phases in order; each has a reference file with the details. Track the
phases with your task list. A typical full run produces: `app.md`, `keyword-research.md`,
`content-roadmap.md`, the site (`index.html`, `guides/`, `styles.css`, `sitemap.xml`,
`robots.txt`, `llms.txt`, `404.html`), `drafts/` + `queue.json`, `scripts/publish_next.py`
config, and a `NEXT-STEPS.md` of human-only actions.

### Phase 1 — Ingest the product

Run `scripts/fetch_app_listing.py <app-store-url-or-id> --out <site-dir>` to pull listing
metadata and download screenshots + icon (it web-scrapes screenshots because the iTunes
API's `screenshotUrls` is often empty, and resizes web variants). For Play Store or
no-store products, pass `--play <url>` or write the fact sheet from the user's
description/project docs. Also check the app repo for RAW fastlane screenshots (`**/fastlane/screenshots/<locale>/`) — prefer them for in-page use (device-frame hero, bento mini-shots); store-marketing screenshots keep their frames/text baked in and only suit og:images and article CTAs. Then READ the screenshots (they're images — look at them) so
captions, alt text, and design decisions come from what the app actually shows.
Write everything into `app.md`: identity, pricing/IAP, description verbatim, per-screenshot
inventory, feature list. The App Store keyword field is private — infer, and say so.

### Phase 2 — Keyword research

Read `references/keyword-research.md`. Ground the keyword set in live SERPs (WebSearch),
not guessed volumes. Deliverables: primary/commercial terms for the index page, one
long-tail question cluster per guide, and — critically — the **wedge**: the
narrow-intent, low-competition cluster this product can own first (the beachhead that
builds authority for head terms later). Write `keyword-research.md` with the page mapping.

### Phase 3 — Build the site

Read `references/page-patterns.md`. Start from `assets/index-template.html`,
`assets/guide-template.html`, `assets/styles-starter.css` — they encode the section
recipe and automation markers; repaint ONLY the :root token block from the app's own visual identity (the token
contract is documented at the top of styles-starter.css); self-host the display font.
The system's centerpiece is a LIVE demo of the app's core interaction in the page —
build it (see the demo section stub in the template). Landing sections: hero (benefit
headline + store CTA + social proof), screenshot rail, how-it-works, features, categorized
guides grid, FAQ, CTA band, footer. Every FAQ answer is self-contained (featured-snippet
quotable) and links "Learn more →" to its guide. Before deploying, run the mobile pass
from page-patterns.md (overflow probe + phone-width screenshot) — desktop-only checks
ship broken phone layouts.

### Phase 4 — Write the guides

The formula that separates content from spam: **answer the searcher's question with real
substance FIRST** — tables, rules, numbers they came for — then the app appears as the
natural way to apply the answer, with a screenshot CTA. Each guide: one H1 with the
keyword near the front, question-form H2s, Article + BreadcrumbList JSON-LD, 2–3
related-guide links. Write the initial live set (6–10), then queue the rest as drafts.

### Phase 5 — Technical SEO + GEO layer

Read `references/technical-seo.md` and `references/llm-visibility.md`. Index page gets
SoftwareApplication + FAQPage JSON-LD; canonicals/OG everywhere; sized lazy images;
sitemap.xml; robots.txt with explicit AI-crawler allows; `llms.txt` fact sheet (from
`assets/llms-template.txt`); branded 404. Then run
`scripts/validate_site.py <site-dir>` — it checks links, HTML balance, and JSON-LD
validity. Fix everything before deploying; run it again before every deploy.

### Phase 6 — Publishing pipeline

Read `references/publishing-pipeline.md`. Write remaining articles into `drafts/` with a
`queue.json` manifest, configure `scripts/publish_next.py` via `site.config.json`, and
install the scheduler the user approved (launchd on macOS, cron on Linux, GitHub Actions
if the site has a remote). Default cadence: 2/week. Also write `content-roadmap.md` with
per-category article ideas so the queue can be refilled.

### Phase 7 — Deploy

Read `references/deploy-hosting.md` — including its pre-deploy safety checklist (shared
buckets, AASA files, existing content). Deploy, invalidate CDN cache, then verify from
outside: curl the domain, a guide, an asset, and confirm content-types. HTTPS is
non-negotiable (ranking signal + browser trust); bare S3 website endpoints are HTTP-only.

### Phase 8 — Indexing + handoff

Walk the user through Google Search Console (Domain property, DNS TXT — create the record
yourself if you have DNS CLI access) and Bing Webmaster Tools (use "Import from GSC" —
Bing's index is what ChatGPT search reads, so this step IS the ChatGPT-visibility step).
Submit the sitemap in both. Finish with `NEXT-STEPS.md`: the human-only work — store
subtitle/ratings, Reddit/listicle outreach, monthly LLM-citation checks — with concrete
instructions per item.

## Redesigning an EXISTING site (vs greenfield)

When the domain already serves a site (recon finds one, or the user says so), the run
changes shape — indexed URLs are earned assets:

- **Inventory first**: pull the live sitemap; every indexed URL must return 200 with
  equivalent-or-better content after your deploy. Restyle existing pages in place —
  never rename or drop a URL without a 301.
- **Back up the bucket** before the first upload (`aws s3 sync s3://<bucket> <backup-dir>`,
  kept outside the site repo or gitignored).
- **Adopt, don't replace**: keep existing FAQ content/JSON-LD, titles, descriptions,
  canonicals unless they're wrong; ensure an adopted llms.txt gains the `## Download`
  anchor the publish script needs; standardize the stylesheet name but leave the old
  CSS file in the bucket so cached HTML keeps styling during propagation.
- New content arrives as queued drafts, not as a big-bang page dump — same cadence
  rules as greenfield.

## Quality bar

- Prefer 8 substantial guides over 25 thin ones; drip-publish the rest. Google's
  scaled-content-abuse policy is real, and LLMs cite pages that actually answer things.
- Every factual claim in guides should survive a spot-check (word counts, grammar rules,
  hour estimates) — these pages represent the user's brand.
- Validate (`scripts/validate_site.py`) before every deploy, no exceptions.
- Report honestly at the end: what's live, what's queued, what's pending (e.g. "sitemap
  submitted, first crawl pending"), and what only the user can do.
