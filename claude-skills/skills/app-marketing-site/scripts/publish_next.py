#!/usr/bin/env python3
"""Publish the next queued article from drafts/ to the live site.

Copy this script into <site>/scripts/ and create <site>/site.config.json. Keys the
script READS: base_url, hosting, s3_bucket, cloudfront_distribution_id. Other keys
(brand, store_url, cadence) are documentation for humans and other tools.

  {
    "base_url": "https://example.com",
    "hosting": "s3-cloudfront",
    "s3_bucket": "my-bucket",
    "cloudfront_distribution_id": "E123ABC"
  }

queue.json titles/cards are PLAIN TEXT — this script HTML-escapes them for the index
card and uses them raw for llms.txt. Do not pre-escape (&amp; etc.) in queue.json.

Per run: pops the first drafts/queue.json entry, moves the draft into guides/, inserts
its card at the <!-- CAT:category --> marker in index.html, appends sitemap.xml and
llms.txt, uploads changed files, invalidates the CDN. The queue pop is committed and
local mutations are kept ONLY after a successful upload — on upload failure everything
is rolled back, so a scheduler retry starts clean. Queue empty -> exits 0 quietly.

Flags: --dry-run  print what would be published, mutate and upload nothing.
"""
import html
import json
import shutil
import subprocess
import sys
from datetime import date
from pathlib import Path

SITE = Path(__file__).resolve().parent.parent
CONFIG = json.loads((SITE / "site.config.json").read_text())
DRAFTS, GUIDES = SITE / "drafts", SITE / "guides"
LOG = SITE / "scripts" / "publish.log"

CARD = """      <a class="guide-card" href="guides/{slug}.html">
        <span class="tag">{tag}</span>
        <h3>{title}</h3>
        <p>{card}</p>
        <span class="more">Read the guide →</span>
      </a>
      <!-- CAT:{category} -->"""


def log(msg):
    line = f"{date.today().isoformat()} {msg}"
    print(line)
    with open(LOG, "a") as f:
        f.write(line + "\n")


def run(cmd):
    subprocess.run(cmd, check=True, capture_output=True, text=True)


def upload(paths, slug):
    if CONFIG["hosting"] != "s3-cloudfront":
        raise RuntimeError(
            f"unsupported hosting {CONFIG['hosting']!r} — adapt upload() for your host")
    bucket = CONFIG["s3_bucket"]
    for p in paths:
        run(["aws", "s3", "cp", str(SITE / p), f"s3://{bucket}/{p}",
             "--cache-control", "public,max-age=600"])
    run(["aws", "cloudfront", "create-invalidation",
         "--distribution-id", CONFIG["cloudfront_distribution_id"],
         "--paths", "/index.html", "/", "/sitemap.xml", "/llms.txt", f"/guides/{slug}.html"])


def main():
    dry = "--dry-run" in sys.argv
    queue_data = json.loads((DRAFTS / "queue.json").read_text())
    if not queue_data["queue"]:
        log("queue empty — nothing to publish")
        return
    art = queue_data["queue"][0]
    slug, category = art["slug"], art["category"]
    draft = DRAFTS / f"{slug}.html"
    index, sitemap, llms = SITE / "index.html", SITE / "sitemap.xml", SITE / "llms.txt"
    marker = f"<!-- CAT:{category} -->"

    originals = {p: p.read_text() for p in (index, sitemap, llms)}
    if not draft.exists():
        log(f"ERROR: draft missing: {draft}"); sys.exit(1)
    if marker not in originals[index]:
        log(f"ERROR: marker {marker} not in index.html"); sys.exit(1)
    if dry:
        log(f"DRY RUN: would publish {slug} ({category}); "
            f"{len(queue_data['queue']) - 1} would remain")
        return

    escaped = {**art, "title": html.escape(art["title"], quote=False),
               "card": html.escape(art["card"], quote=False),
               "tag": html.escape(art["tag"], quote=False)}
    shutil.move(str(draft), str(GUIDES / f"{slug}.html"))
    index.write_text(originals[index].replace(marker, CARD.format(**escaped), 1))
    sitemap.write_text(originals[sitemap].replace(
        "</urlset>",
        f"  <url><loc>{CONFIG['base_url']}/guides/{slug}.html</loc>"
        f"<priority>0.7</priority></url>\n</urlset>"))
    llms.write_text(originals[llms].replace(
        "\n## Download",
        f"- [{art['title']}]({CONFIG['base_url']}/guides/{slug}.html): {art['card']}"
        f"\n\n## Download"))

    try:
        upload(["index.html", "sitemap.xml", "llms.txt", f"guides/{slug}.html"], slug)
    except Exception as e:
        for p, content in originals.items():
            p.write_text(content)
        shutil.move(str(GUIDES / f"{slug}.html"), str(draft))
        log(f"ERROR: upload failed, rolled back local changes: {e}")
        sys.exit(1)

    queue_data["queue"] = queue_data["queue"][1:]
    (DRAFTS / "queue.json").write_text(
        json.dumps(queue_data, indent=2, ensure_ascii=False) + "\n")
    log(f"published {slug} ({category}); {len(queue_data['queue'])} left in queue")


if __name__ == "__main__":
    main()
