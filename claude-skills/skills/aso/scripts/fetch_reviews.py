#!/usr/bin/env python3
"""Fetch recent App Store reviews via the public RSS feed (no credentials).

Usage: python3 fetch_reviews.py <app_id> <country> [<country> ...] [--pages 2]

Prints JSON: per storefront, a list of {rating, title, body, version, author, date}.
The feed returns ~50 most recent reviews per page. Mine the output for recurring
complaints, feature requests, and users' natural vocabulary (keyword-field input).
Note: the feed only includes reviews WITH text — star-only ratings don't appear, so
rating velocity must come from the lookup API's ratingCount delta, not from here.
"""
import json
import sys
import urllib.request

def fetch_page(app_id, country, page):
    url = (f"https://itunes.apple.com/{country}/rss/customerreviews/"
           f"page={page}/id={app_id}/sortby=mostrecent/json")
    try:
        with urllib.request.urlopen(url, timeout=30) as r:
            data = json.load(r)
    except Exception:
        return []
    entries = data.get("feed", {}).get("entry", [])
    if isinstance(entries, dict):
        entries = [entries]
    out = []
    for e in entries:
        if "im:rating" not in e:  # first entry is app metadata on some storefronts
            continue
        out.append({
            "rating": int(e["im:rating"]["label"]),
            "title": e.get("title", {}).get("label", ""),
            "body": e.get("content", {}).get("label", ""),
            "version": e.get("im:version", {}).get("label", ""),
            "author": e.get("author", {}).get("name", {}).get("label", ""),
            "date": e.get("updated", {}).get("label", "")[:10],
        })
    return out

def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    if len(args) < 2:
        sys.exit(__doc__)
    pages = int(sys.argv[sys.argv.index("--pages") + 1]) if "--pages" in sys.argv else 2
    app_id, countries = args[0], args[1:]
    out = {}
    for c in countries:
        reviews = []
        for p in range(1, pages + 1):
            reviews.extend(fetch_page(app_id, c, p))
        out[c] = reviews
        print(f"  {c}: {len(reviews)} reviews with text", file=sys.stderr)
    json.dump(out, sys.stdout, indent=2, ensure_ascii=False)
    print()

if __name__ == "__main__":
    main()
