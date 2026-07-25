#!/usr/bin/env python3
"""Keyword rank proxy via the iTunes Search API.

Usage: python3 keyword_ranks.py <config.json> [--limit 100]

Reads target_keywords + storefronts + app_id from the aso config and prints a JSON rank
table: position of the app in iTunes search results per keyword per storefront (null if
not in the top N). The Search API's ordering approximates App Store search — treat
positions as a trend proxy, not gospel. Sleeps between calls; the API rate-limits
(~20 req/min) — a 20-keyword × 3-storefront run takes ~3 minutes.
"""
import json
import sys
import time
import urllib.parse
import urllib.request

def search(term, country, limit):
    url = ("https://itunes.apple.com/search?media=software&entity=software"
           f"&term={urllib.parse.quote(term)}&country={country}&limit={limit}")
    with urllib.request.urlopen(url, timeout=30) as r:
        return json.load(r).get("results", [])

def main():
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    cfg = json.load(open(sys.argv[1]))
    limit = int(sys.argv[sys.argv.index("--limit") + 1]) if "--limit" in sys.argv else 100
    app_id = int(cfg["app_id"])
    out = {}
    for country in cfg["storefronts"]:
        out[country] = {}
        for kw in cfg["target_keywords"]:
            try:
                results = search(kw, country, limit)
                pos = next((i + 1 for i, r in enumerate(results)
                            if r.get("trackId") == app_id), None)
                out[country][kw] = pos
                total = len(results)
                print(f"  {country} {kw!r}: "
                      f"{'#' + str(pos) if pos else f'not in top {total}'}",
                      file=sys.stderr)
            except Exception as e:
                out[country][kw] = f"error: {e}"
                print(f"  {country} {kw!r}: ERROR {e}", file=sys.stderr)
            time.sleep(3.5)
    json.dump(out, sys.stdout, indent=2, ensure_ascii=False)
    print()

if __name__ == "__main__":
    main()
