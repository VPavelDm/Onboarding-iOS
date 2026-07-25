#!/usr/bin/env python3
"""Fill TranslationText in an AppScreens export CSV from captions/captions.json.

Rules (see references/appscreens-csv.md + localizing-captions.md):
  - BaseText is the match key and is never modified.
  - en-US (source language) TranslationText mirrors BaseText.
  - A BaseText matching any keepEnglishBasePrefixes stays English for every locale.
  - <b>/<i>/<u> outer wrapper on BaseText is preserved around the localized inner text.
  - Rows with no caption entry / no translation for that locale keep their existing value.

Usage:
  translate_captions_csv.py --export in.csv --data captions.json --out out.csv
"""
from __future__ import annotations
import argparse, csv, json, re, sys

WRAP = re.compile(r"^<(b|i|u)>(.*)</\1>$", re.S)

def wrap_like(base: str, inner: str) -> str:
    """Wrap `inner` in the same single outer tag `base` uses, if any."""
    m = WRAP.match(base.strip())
    return f"<{m.group(1)}>{inner}</{m.group(1)}>" if m else inner

def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--export", required=True)
    ap.add_argument("--data", required=True)
    ap.add_argument("--out", required=True)
    ap.add_argument("--source-lang", default="en-US")
    args = ap.parse_args()

    data = json.load(open(args.data, encoding="utf-8"))
    caps = data.get("captions", {})
    keep_prefixes = tuple(data.get("keepEnglishBasePrefixes", []))

    with open(args.export, newline="", encoding="utf-8-sig") as f:
        rows = list(csv.DictReader(f))
    if not rows:
        sys.exit("empty export CSV")
    fieldnames = list(rows[0].keys())
    required = ["BaseText", "TranslationLanguage", "TranslationText"]
    missing = [c for c in required if c not in fieldnames]
    if missing:
        sys.exit(f"export CSV missing columns: {missing}")

    changed = 0
    for r in rows:
        base, lang = r["BaseText"], r["TranslationLanguage"]
        new = r["TranslationText"]
        if lang == args.source_lang:
            new = base                                   # source mirrors base
        elif base.startswith(keep_prefixes) and keep_prefixes:
            new = base                                   # intentionally English
        else:
            entry = caps.get(base)
            if entry and lang in entry.get("translations", {}):
                new = wrap_like(base, entry["translations"][lang])
            # else: leave existing TranslationText untouched
        if new != r["TranslationText"]:
            r["TranslationText"] = new
            changed += 1

    with open(args.out, "w", newline="", encoding="utf-8-sig") as f:
        w = csv.DictWriter(f, fieldnames=fieldnames)
        w.writeheader()
        w.writerows(rows)
    print(f"rows: {len(rows)}  updated TranslationText: {changed}  -> {args.out}")

if __name__ == "__main__":
    main()
