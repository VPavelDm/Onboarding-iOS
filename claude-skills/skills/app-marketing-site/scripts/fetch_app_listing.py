#!/usr/bin/env python3
"""Fetch an App Store listing: metadata + screenshots + icon.

Usage:
  python3 fetch_app_listing.py <app-store-url-or-numeric-id> --out <site-dir> [--country us]

Writes:
  <site-dir>/assets/screenshot-N.png (full res) + screenshot-N-800.png (web variant)
  <site-dir>/assets/app-icon.png (1024) + app-icon-360.png + favicon-64.png
  <site-dir>/listing.json (raw metadata for Claude to turn into app.md)

Why the scrape: the iTunes Lookup API's screenshotUrls is often EMPTY even when the
listing has screenshots — the store web page (fetched with a browser User-Agent; the
default UA gets a 2KB shell) contains templated mzstatic URLs we can render at any size.
The first N unique numbered screenshots in document order = the primary gallery set.
"""
import json
import re
import subprocess
import sys
import urllib.request
from pathlib import Path

UA = ("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 "
      "(KHTML, like Gecko) Version/17.0 Safari/605.1.15")
SHOT_SIZE = "1290x2796bb.png"   # 6.9-inch render; mzstatic scales to fit
WEB_WIDTH = 800


def fetch(url, ua=None):
    req = urllib.request.Request(url, headers={"User-Agent": ua or "curl/8"})
    return urllib.request.urlopen(req, timeout=30).read()


def resize(src: Path, dest: Path, max_dim: int):
    try:  # sips on macOS; Pillow elsewhere; else skip with a warning
        subprocess.run(["sips", "-Z", str(max_dim), str(src), "--out", str(dest)],
                       check=True, capture_output=True)
        return
    except (FileNotFoundError, subprocess.CalledProcessError):
        pass
    try:
        from PIL import Image
        img = Image.open(src)
        img.thumbnail((max_dim, max_dim))
        img.save(dest)
    except ImportError:
        print(f"  WARNING: no sips/Pillow — skipping resize for {dest.name}; "
              f"create web variants manually before deploying")


def main():
    args = sys.argv[1:]
    if not args:
        sys.exit(__doc__)
    m = re.search(r"id(\d+)", args[0]) or re.match(r"^(\d+)$", args[0])
    if not m:
        sys.exit(f"could not find a numeric app id in {args[0]!r}")
    app_id = m.group(1)
    out = Path(args[args.index("--out") + 1]) if "--out" in args else Path(".")
    country = args[args.index("--country") + 1] if "--country" in args else "us"
    assets = out / "assets"
    assets.mkdir(parents=True, exist_ok=True)

    # 1. metadata via lookup API
    data = json.loads(fetch(
        f"https://itunes.apple.com/lookup?id={app_id}&country={country}"))
    if not data.get("resultCount"):
        sys.exit(f"app id {app_id} not found in {country} storefront")
    meta = data["results"][0]
    (out / "listing.json").write_text(json.dumps(meta, indent=2, ensure_ascii=False))
    print(f"metadata: {meta.get('trackName')!r} v{meta.get('version')} "
          f"rating {meta.get('averageUserRating')} ({meta.get('userRatingCount')} ratings)")

    # 2. icon
    icon_url = meta["artworkUrl512"].replace("512x512bb.jpg", "1024x1024bb.png")
    (assets / "app-icon.png").write_bytes(fetch(icon_url))
    resize(assets / "app-icon.png", assets / "app-icon-360.png", 360)
    resize(assets / "app-icon.png", assets / "favicon-64.png", 64)

    # 3. screenshots: scrape the web listing (browser UA required)
    page_url = meta.get("trackViewUrl", "").split("?")[0] or \
        f"https://apps.apple.com/{country}/app/id{app_id}"
    html = fetch(page_url, ua=UA).decode("utf-8", "replace")
    # Screenshot basenames vary by app: "01.png", "iPhones__6.9-02.png",
    # "iPad__13-ipadPro129-01.png"... Strategy: collect every numbered image template
    # (skipping AppIcon/banner assets), group by basename prefix, prefer the iPhone
    # group (else the largest), dedupe by number keeping document order, sort by number.
    pat = re.compile(
        r'https://is\d-ssl\.mzstatic\.com/image/thumb/[^"]+?/([^/"]+?)(\d{1,2})\.png'
        r'/\{w\}x\{h\}\{c\}\.\{f\}')
    groups = {}
    for m2 in pat.finditer(html):
        prefix, num = m2.group(1), m2.group(2)
        if prefix.startswith("AppIcon"):
            continue
        groups.setdefault(prefix, {}).setdefault(num, m2.group(0))
    shots = []
    if groups:
        iphone = [p for p in groups if "iphone" in p.lower()]
        best = (sorted(iphone, key=lambda p: -len(groups[p]))[0] if iphone
                else max(groups, key=lambda p: len(groups[p])))
        print(f"screenshot set: prefix {best!r} ({len(groups[best])} images; "
              f"groups found: {list(groups)})")
        shots = [groups[best][n] for n in sorted(groups[best])]
    if not shots:
        print("WARNING: no screenshots found on the web page — check the listing manually")
    for i, tmpl in enumerate(shots, 1):
        url = tmpl.replace("{w}x{h}{c}.{f}", SHOT_SIZE)
        dest = assets / f"screenshot-{i}.png"
        dest.write_bytes(fetch(url))
        resize(dest, assets / f"screenshot-{i}-{WEB_WIDTH}.png", WEB_WIDTH)
        print(f"screenshot-{i}.png ({len(dest.read_bytes())//1024} KB)")

    print(f"\nDone: {len(shots)} screenshots + icon in {assets}/, metadata in listing.json")
    print("Next: READ the screenshots (they are images) before writing captions/alt text,")
    print("and note the keyword field is private — infer keywords from the copy.")


if __name__ == "__main__":
    main()
