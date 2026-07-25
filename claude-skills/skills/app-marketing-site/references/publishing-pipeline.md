# Publishing Pipeline (drip-release)

## Why drip instead of publish-everything

Google's "scaled content abuse" policy targets exactly the pattern of 30 pages appearing
overnight on a fresh domain; steady cadence reads as a living site to crawlers and gives
each article its own crawl/index cycle. **Default: 2 articles/week.** More than 3/week on
a new domain is asking for trouble; 1/week is fine too. Ask the user in the upfront
question round (it also determines whether to install a scheduler on their machine).

## Layout

```
site/
├── drafts/                 # finished articles waiting for release
│   ├── <slug>.html         # complete pages, canonical already pointing at guides/<slug>.html
│   └── queue.json          # ordered manifest (see assets/site.config.example.json for schema)
├── guides/                 # live articles
├── scripts/publish_next.py # copy of the skill's script, config-driven
└── site.config.json        # domain, hosting IDs, cadence
```

`queue.json` entries: `slug`, `category` (must match a `<!-- CAT:x -->` marker in
index.html), `tag` (card label), `title`, `card` (2-line description). Order = release
order; interleave categories for variety. Titles/cards are PLAIN TEXT — the publish
script HTML-escapes them for the index card (never pre-escape with &amp; in queue.json).

## What publish_next.py does per run

1. Pops the first queue entry; moves `drafts/<slug>.html` → `guides/`.
2. Inserts the guide card into index.html at its `<!-- CAT:category -->` marker
   (marker stays, after the new card, for the next insert).
3. Appends the sitemap.xml `<url>` entry and an llms.txt guide line. llms.txt MUST
   contain a `## Download` heading — the script inserts before it. Greenfield templates
   have it; when adopting an EXISTING llms.txt (redesigns), add the anchor or inserts
   silently never happen.
4. Uploads changed files to hosting, invalidates CDN, logs to `scripts/publish.log`.
5. Queue empty → logs and exits 0 (safe to leave scheduled). Upload failure rolls back
   all local mutations, so a retry starts clean; `--dry-run` previews without changes.

The markers are load-bearing: never remove them when editing index.html, and category
names in queue.json must match markers exactly.

## Schedulers by platform

- **macOS**: launchd user agent (`~/Library/LaunchAgents/com.<brand>.publish-article.plist`),
  `StartCalendarInterval` array (e.g. Tue+Fri 10:00), stdout/err → publish.log. Load with
  `launchctl bootstrap gui/$(id -u) <plist>`, verify with `launchctl list | grep <label>`.
  launchd coalesces missed runs on wake — survives sleep, not shutdown. Tell the user this.
- **Linux**: crontab `0 10 * * 2,5 /usr/bin/python3 <path>/publish_next.py`.
- **GitHub Actions** (if the site repo has a remote — most robust, machine-independent):
  `schedule:` cron workflow running the script with hosting credentials in repo secrets.

## Refilling the queue

Write `content-roadmap.md`: per-category tables of LIVE / queued / idea rows, each idea
with its target keyword, plus the writing rules (guide formula from page-patterns.md).
When asked for "more articles", write drafts + append queue entries; never publish
directly to guides/ by hand — it bypasses index/sitemap/llms.txt updates.

## Versioning

`git init` the site directory at the end (publish runs modify tracked files; note this).
Offer to push to a private remote — otherwise the queue exists only on one disk + hosting.
