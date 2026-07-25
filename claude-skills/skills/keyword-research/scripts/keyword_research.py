#!/usr/bin/env python3
"""App Store keyword validation via live autocomplete + the iTunes Search API.

Modes:
  suggest   python3 keyword_research.py suggest "time capsule" "future letter" --country us
            Print App Store autocomplete expansions for seed terms — use while
            building the keyword universe (these are real user queries).

  research  python3 keyword_research.py research keywords.txt --country us [--limit 25]
            For each candidate keyword (one per line) print a JSON row with:
            - autocomplete: exact-match presence + priority (popularity proxy;
              priority is Apple's own hint ranking when the endpoint returns it)
            - competition: number of results, median rating count of the top 10,
              and the top 5 apps with their rating counts (can a small app rank?)

Both endpoints are public and unauthenticated. Rate limits are real (~20 req/min)
so the script sleeps between calls — 40 keywords take ~5 minutes. Treat all
numbers as proxies: autocomplete ≈ demand, top-10 rating mass ≈ competition.
"""
import json
import plistlib
import re
import sys
import time
import urllib.parse
import urllib.request

# X-Apple-Store-Front ids for common storefronts; unknown countries fall back to US
# (say so in the report if that happens).
STOREFRONTS = {
    "us": 143441, "gb": 143444, "de": 143443, "fr": 143442, "it": 143450,
    "es": 143454, "ca": 143455, "au": 143460, "jp": 143462, "nl": 143452,
    "se": 143456, "no": 143457, "dk": 143458, "ch": 143459, "at": 143445,
    "be": 143446, "fi": 143447, "pt": 143453, "br": 143503, "mx": 143468,
    "pl": 143478, "in": 143467, "kr": 143466, "tr": 143480,
}

SLEEP = 3.5


def hints(term, country):
    sf = STOREFRONTS.get(country.lower(), STOREFRONTS["us"])
    url = ("https://search.itunes.apple.com/WebObjects/MZSearchHints.woa/wa/hints"
           f"?clientApplication=Software&term={urllib.parse.quote(term)}")
    req = urllib.request.Request(url, headers={"X-Apple-Store-Front": f"{sf}-1,29"})
    with urllib.request.urlopen(req, timeout=30) as r:
        data = r.read()
    try:
        pl = plistlib.loads(data)
        return [(h.get("term", ""), h.get("priority")) for h in pl.get("hints", [])]
    except Exception:
        terms = re.findall(r"<string>(.*?)</string>", data.decode("utf-8", "ignore"))
        return [(t, None) for t in terms]


def search(term, country, limit):
    url = ("https://itunes.apple.com/search?media=software&entity=software"
           f"&term={urllib.parse.quote(term)}&country={country}&limit={limit}")
    with urllib.request.urlopen(url, timeout=30) as r:
        return json.load(r).get("results", [])


def research_row(term, country, limit):
    hint_list = hints(term, country)
    exact = next(((t, p) for t, p in hint_list if t.lower() == term.lower()), None)
    time.sleep(SLEEP)
    results = search(term, country, limit)
    counts = sorted(r.get("userRatingCount", 0) for r in results[:10])
    median = counts[len(counts) // 2] if counts else 0
    return {
        "keyword": term,
        "autocomplete": {
            "exact_match": exact is not None,
            "priority": exact[1] if exact else None,
            "top_hints": [t for t, _ in hint_list[:5]],
        },
        "competition": {
            "results": len(results),
            "top10_median_ratings": median,
            "top5": [{"name": r.get("trackName"),
                      "ratings": r.get("userRatingCount", 0)} for r in results[:5]],
        },
    }


def main():
    args = sys.argv[1:]
    if not args or args[0] not in ("suggest", "research"):
        sys.exit(__doc__)
    mode = args[0]
    country = args[args.index("--country") + 1] if "--country" in args else "us"
    limit = int(args[args.index("--limit") + 1]) if "--limit" in args else 25
    positional = [a for a in args[1:] if not a.startswith("--")
                  and a not in (country, str(limit))]

    if mode == "suggest":
        out = {}
        for seed in positional:
            try:
                out[seed] = [{"term": t, "priority": p} for t, p in hints(seed, country)]
                print(f"  {seed!r}: {len(out[seed])} hints", file=sys.stderr)
            except Exception as e:
                out[seed] = f"error: {e}"
                print(f"  {seed!r}: ERROR {e}", file=sys.stderr)
            time.sleep(SLEEP)
        json.dump(out, sys.stdout, indent=2, ensure_ascii=False)
        print()
        return

    keywords = [ln.strip() for ln in open(positional[0]) if ln.strip()]
    rows = []
    for i, kw in enumerate(keywords):
        try:
            row = research_row(kw, country, limit)
            ac = row["autocomplete"]
            comp = row["competition"]
            print(f"  [{i+1}/{len(keywords)}] {kw!r}: "
                  f"autocomplete={'yes' if ac['exact_match'] else 'no'}"
                  f"{' p=' + str(ac['priority']) if ac['priority'] is not None else ''}, "
                  f"top10 median ratings={comp['top10_median_ratings']}",
                  file=sys.stderr)
        except Exception as e:
            row = {"keyword": kw, "error": str(e)}
            print(f"  [{i+1}/{len(keywords)}] {kw!r}: ERROR {e}", file=sys.stderr)
        rows.append(row)
        time.sleep(SLEEP)
    json.dump(rows, sys.stdout, indent=2, ensure_ascii=False)
    print()


if __name__ == "__main__":
    main()
