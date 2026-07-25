#!/usr/bin/env python3
"""Validate an AppScreens import CSV before the user imports it. Stdlib only.

Usage:
  check_captions_csv.py --import out.csv [--export in.csv] [--source-lang en-US]

Checks:
  - HEADER      : headers identical (order + names) to the export, if given.
  - RICH TEXT   : TranslationText uses only <b> <i> <u> <br> and color/background-color spans,
                  with balanced tags.
  - EMPTY       : non-source TranslationText is empty.
  - UNTRANSLATED: non-source TranslationText equals BaseText (likely forgotten) — warning.
  - SUBSET      : every import row identity (Screenshot,TextBox,TranslationLanguage) exists in
                  the export (AppScreens only replaces present rows), if export given.
Exit non-zero on any hard error (HEADER/RICH TEXT/EMPTY/SUBSET).
"""
from __future__ import annotations
import argparse, csv, re, sys
from html.parser import HTMLParser

ALLOWED = {"b", "i", "u", "br", "span"}
STYLE_OK = re.compile(r"^\s*(color|background-color)\s*:\s*#[0-9a-fA-F]{6,8}\s*;?\s*$")

class TagCheck(HTMLParser):
    def __init__(self):
        super().__init__()
        self.stack, self.errors = [], []
    def handle_starttag(self, tag, attrs):
        if tag not in ALLOWED:
            self.errors.append(f"disallowed <{tag}>")
            return
        if tag == "br":
            return
        if tag == "span":
            style = dict(attrs).get("style", "")
            if not STYLE_OK.match(style or ""):
                self.errors.append(f"span style not allowed: {style!r}")
        self.stack.append(tag)
    def handle_endtag(self, tag):
        if tag == "br":
            return
        if not self.stack or self.stack[-1] != tag:
            self.errors.append(f"unbalanced </{tag}>")
        else:
            self.stack.pop()

def richtext_errors(text: str) -> list[str]:
    p = TagCheck(); p.feed(text)
    errs = list(p.errors)
    if p.stack:
        errs.append(f"unclosed {p.stack}")
    return errs

def read(path):
    with open(path, newline="", encoding="utf-8-sig") as f:
        rows = list(csv.DictReader(f))
    return rows, (list(rows[0].keys()) if rows else [])

def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--import", dest="imp", required=True)
    ap.add_argument("--export", dest="exp")
    ap.add_argument("--data", help="captions.json — used to skip intentionally-English rows")
    ap.add_argument("--source-lang", default="en-US")
    args = ap.parse_args()

    keep_prefixes = ()
    if args.data:
        import json
        keep_prefixes = tuple(json.load(open(args.data, encoding="utf-8")).get("keepEnglishBasePrefixes", []))

    rows, fields = read(args.imp)
    if not rows:
        sys.exit("empty import CSV")
    errors, warnings = [], []

    EXPECTED = ["Screenshot", "TextBox", "Subtitle", "BaseLanguage",
                "BaseText", "TranslationLanguage", "TranslationText"]
    if fields != EXPECTED:
        # tolerate as long as required columns exist, but flag drift
        if [c for c in ("BaseText", "TranslationLanguage", "TranslationText") if c not in fields]:
            sys.exit(f"HEADER: missing required columns; got {fields}")
        warnings.append(f"HEADER: columns differ from the canonical order/name set: {fields}")

    exp_ids = None
    if args.exp:
        erows, efields = read(args.exp)
        if efields != fields:
            errors.append(f"HEADER: import headers {fields} != export headers {efields}")
        exp_ids = {(r["Screenshot"], r["TextBox"], r["TranslationLanguage"]) for r in erows}

    for i, r in enumerate(rows, 2):  # row 2 = first data row
        lang, base, tt = r["TranslationLanguage"], r["BaseText"], r["TranslationText"]
        for e in richtext_errors(tt):
            errors.append(f"RICH TEXT row {i} ({lang}): {e}  |  {tt!r}")
        keep_english = bool(keep_prefixes) and base.startswith(keep_prefixes)
        if lang != args.source_lang and not keep_english:
            if tt.strip() == "":
                errors.append(f"EMPTY row {i} ({lang}) for BaseText {base!r}")
            elif tt.strip() == base.strip():
                warnings.append(f"UNTRANSLATED row {i} ({lang}): TranslationText == BaseText")
        if exp_ids is not None:
            ident = (r["Screenshot"], r["TextBox"], lang)
            if ident not in exp_ids:
                errors.append(f"SUBSET row {i}: {ident} not in export (AppScreens won't match it)")

    for w in warnings:
        print("WARN ", w)
    for e in errors:
        print("ERROR", e)
    print(f"\n{len(rows)} rows — {len(errors)} error(s), {len(warnings)} warning(s).")
    sys.exit(1 if errors else 0)

if __name__ == "__main__":
    main()
