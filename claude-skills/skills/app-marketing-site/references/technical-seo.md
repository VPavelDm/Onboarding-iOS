# Technical SEO

## Structured data (JSON-LD)

- **Index page**: `SoftwareApplication` (name, alternateName, operatingSystem,
  applicationCategory, description, offers, aggregateRating from the live listing,
  downloadUrl, image) + `FAQPage` (mainEntity mirroring the visible FAQ, plain-text
  answers). After a rebrand, keep the old public name as `alternateName` for a few months
  — it preserves the search-engine entity association during the transition.
- **Guide pages**: `Article` (headline, description, image, author/publisher = brand) +
  `BreadcrumbList` (Home → Guides → page).
- **Zero/low ratings**: if the listing has no ratings (or a trivial count), OMIT
  `aggregateRating` entirely — empty/zero values are schema spam and fabricated stars
  are worse. Replace star social proof in the hero/CTA with content stats (word counts,
  levels, languages). Same rule for the `{{RATING}}` slots in the templates.
- Validate every block parses as JSON (the validator script does this) — one trailing
  comma silently kills the whole block for crawlers.

## Head checklist (every page)

`<title>` ≤ 60 chars with keyword near front · meta description 140–160 chars · canonical
absolute URL · og:type/title/description/image (+ twitter:card) · favicon + apple-touch-icon
· `<html lang>` correct.

## Images

- Never ship store-resolution screenshots to the page: create ~800px web variants
  (the fetch script does this via `sips` on macOS; `magick`/`convert` elsewhere) and keep
  originals available, but og:image should be a ≤1200px variant (aim <300 KB) —
  multi-MB og:images make link unfurlers time out.
- Explicit `width`/`height` on every `<img>` (prevents layout shift), `loading="lazy"`
  below the fold, `fetchpriority="high"` on the hero image only.
- Alt text: describe what the screenshot shows, keyword-adjacent, never stuffed
  ("Der die das article training exercise for the noun Fernweh" — not "german app
  learn german words app german").

## Site files

- `sitemap.xml` — all pages, index priority 1.0, guides 0.7–0.8. The publish script
  appends on every release. Submit in Search Console + Bing once.
- `robots.txt` — `User-agent: * / Allow: /`, explicit allows for AI crawlers (see
  llm-visibility.md), `Sitemap:` line.
- `404.html` — branded, with store CTA; wire the host's error pages to it (on CloudFront:
  custom error responses for 403 AND 404, because S3 origins without ListBucket return
  403 for missing keys).

## URLs

Flat `guides/<keyword-slug>.html` is fine — slug = the target keyword, hyphenated. Don't
churn URLs after publishing; if you must, 301. Extension-less "pretty" URLs need
host-level rewrites (CloudFront Function) — not worth it at launch.

## Multi-page consistency traps (learned the hard way)

- A rebrand or copy change must sweep EVERYWHERE: titles, og tags, JSON-LD, alt text,
  visible copy, footer. `grep -rn "OldName" site/` before every deploy.
- Canonicals/OG URLs must match the real deployed domain exactly (https, no trailing
  ambiguity). One assumed-wrong domain = every page canonicalizing to nowhere.
