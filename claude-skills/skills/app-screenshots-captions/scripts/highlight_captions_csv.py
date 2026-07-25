#!/usr/bin/env python3
"""Wrap the per-locale highlight substring of each caption in an accent color span.

Operates on the already-translated AppScreens CSV. For each row whose BaseText is a caption
in captions.json, wraps that locale's highlight substring in
`<span style="color:<highlightColor>">…</span>`. Warns on every miss (substring not found,
or no highlight defined) so typos surface before import. Idempotent: rows already containing
a <span> are skipped.

Usage:
  highlight_captions_csv.py --in in.csv --data captions.json --out out.csv
"""
from __future__ import annotations
import argparse, csv, json, sys

def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--in", dest="inp", required=True)
    ap.add_argument("--data", required=True)
    ap.add_argument("--out", required=True)
    ap.add_argument("--source-lang", default="en-US")
    args = ap.parse_args()

    data = json.load(open(args.data, encoding="utf-8"))
    caps = data.get("captions", {})
    color = data.get("highlightColor", "#ffd42eff")

    with open(args.inp, newline="", encoding="utf-8-sig") as f:
        rows = list(csv.DictReader(f))
    fieldnames = list(rows[0].keys())

    wrapped, misses = 0, []
    for r in rows:
        entry = caps.get(r["BaseText"])
        if not entry:
            continue                                   # not a caption row
        lang = r["TranslationLanguage"]
        sub = entry.get("highlight", {}).get(lang)
        text = r["TranslationText"]
        if "<span" in text:
            continue                                   # already highlighted
        if not sub:
            misses.append(f"no highlight for {lang}: {r['BaseText']!r}")
            continue
        if sub not in text:
            misses.append(f"substring not in translation ({lang}): {sub!r} not in {text!r}")
            continue
        r["TranslationText"] = text.replace(sub, f'<span style="color:{color}">{sub}</span>', 1)
        wrapped += 1

    with open(args.out, "w", newline="", encoding="utf-8-sig") as f:
        w = csv.DictWriter(f, fieldnames=fieldnames)
        w.writeheader()
        w.writerows(rows)

    print(f"highlighted {wrapped} caption(s) -> {args.out}")
    if misses:
        print(f"ISSUES ({len(misses)}) — resolve before importing:")
        for m in misses:
            print("  -", m)
        sys.exit(1)

if __name__ == "__main__":
    main()
