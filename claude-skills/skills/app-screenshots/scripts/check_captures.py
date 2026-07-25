#!/usr/bin/env python3
"""Verify a fastlane screenshots output directory: completeness + sanity, stdlib only.

Usage:
  check_captures.py [--app-dir .] [--dir fastlane/screenshots] [--config screenshots/config.json]

Checks (relative to a reference locale — the one with the most shots, usually en-US):
  - MISSING       : a shot present in the reference locale but absent in another locale.
  - EXTRA         : a shot in a locale but not in the reference.
  - SIZE MISMATCH : a PNG whose dimensions differ from the reference shot of the same name.
  - LIKELY EN FALLBACK : a non-reference shot byte-identical to the reference (same pixels
                    => the demo string wasn't translated for that locale).
  - SUSPICIOUS SIZE : a file far smaller than its peers for the same shot (possible blank/
                    crash/loading capture).
Exit code is non-zero if any MISSING or SIZE MISMATCH is found.
"""
import argparse, os, sys, json, hashlib, struct, statistics
from collections import defaultdict

def png_size(path):
    """(width, height) from the PNG IHDR, or None."""
    try:
        with open(path, "rb") as f:
            head = f.read(24)
        if head[:8] != b"\x89PNG\r\n\x1a\n" or head[12:16] != b"IHDR":
            return None
        return struct.unpack(">II", head[16:24])
    except OSError:
        return None

def sha(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 16), b""):
            h.update(chunk)
    return h.hexdigest()

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--app-dir", default=".")
    ap.add_argument("--dir", default=None, help="output dir (default: from config or fastlane/screenshots)")
    ap.add_argument("--config", default="screenshots/config.json")
    args = ap.parse_args()

    os.chdir(args.app_dir)
    out = args.dir
    cfg = {}
    if os.path.exists(args.config):
        cfg = json.load(open(args.config))
        out = out or cfg.get("outputDir")
    out = out or "fastlane/screenshots"
    if not os.path.isdir(out):
        print(f"error: output dir not found: {out}", file=sys.stderr); sys.exit(2)

    # locale dir = any subdir containing at least one .png
    locales = {}
    for name in sorted(os.listdir(out)):
        d = os.path.join(out, name)
        if not os.path.isdir(d):
            continue
        pngs = [f for f in os.listdir(d) if f.lower().endswith(".png")]
        if pngs:
            locales[name] = sorted(pngs)
    if not locales:
        print(f"error: no locale folders with PNGs under {out}", file=sys.stderr); sys.exit(2)

    # reference = most shots (ties: en-US if present, else first alpha)
    ref = max(locales, key=lambda l: (len(locales[l]), l == "en-US"))
    ref_files = set(locales[ref])
    print(f"reference locale: {ref} ({len(ref_files)} shots)\n")

    problems = 0
    warnings = 0

    # per-shot sizes for the suspicious-size heuristic
    sizes_by_shot = defaultdict(list)
    for loc, files in locales.items():
        for fn in files:
            p = os.path.join(out, loc, fn)
            sizes_by_shot[fn].append((loc, os.path.getsize(p)))

    ref_hashes = {fn: sha(os.path.join(out, ref, fn)) for fn in ref_files}
    ref_dims = {fn: png_size(os.path.join(out, ref, fn)) for fn in ref_files}

    for loc in sorted(locales):
        files = set(locales[loc])
        missing = ref_files - files
        extra = files - ref_files
        for fn in sorted(missing):
            print(f"MISSING          {loc}/{fn}"); problems += 1
        for fn in sorted(extra):
            print(f"EXTRA            {loc}/{fn}"); warnings += 1
        if loc == ref:
            continue
        for fn in sorted(files & ref_files):
            p = os.path.join(out, loc, fn)
            if png_size(p) != ref_dims.get(fn):
                print(f"SIZE MISMATCH    {loc}/{fn}  {png_size(p)} != ref {ref_dims.get(fn)}")
                problems += 1
            if sha(p) == ref_hashes.get(fn):
                print(f"LIKELY EN FALLBACK {loc}/{fn}  (identical to {ref} — untranslated demo string?)")
                warnings += 1

    # suspicious small files (< 40% of median for that shot)
    for fn, entries in sizes_by_shot.items():
        if len(entries) < 3:
            continue
        med = statistics.median(s for _, s in entries)
        for loc, s in entries:
            if s < 0.4 * med:
                print(f"SUSPICIOUS SIZE  {loc}/{fn}  {s}B vs median {int(med)}B (blank/crash?)")
                warnings += 1

    print(f"\n{len(locales)} locales, ~{len(ref_files)} shots each. "
          f"{problems} problem(s), {warnings} warning(s).")
    sys.exit(1 if problems else 0)

if __name__ == "__main__":
    main()
