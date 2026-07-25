#!/usr/bin/env python3
"""Validate a static site before deploying: local links, HTML tag balance, JSON-LD.

Usage: python3 validate_site.py <site-dir>

Checks index.html, 404.html, guides/*.html and drafts/*.html (drafts may link to queued
siblings that will publish later, so a target counts as present if it exists in either
guides/ or drafts/). Exits 1 on any failure — wire this into every deploy.
"""
import glob
import json
import os
import re
import sys
from html.parser import HTMLParser

VOID = {"meta", "link", "img", "br", "hr", "input", "source", "wbr", "track", "area"}


class BalanceChecker(HTMLParser):
    def __init__(self):
        super().__init__()
        self.stack, self.errors = [], []

    def handle_starttag(self, tag, attrs):
        if tag not in VOID:
            self.stack.append(tag)

    def handle_endtag(self, tag):
        if tag in VOID:
            return
        if self.stack and self.stack[-1] == tag:
            self.stack.pop()
        else:
            self.errors.append(f"mismatched </{tag}> (open: {self.stack[-3:]})")


def main():
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    os.chdir(sys.argv[1])
    pages = (glob.glob("index.html") + glob.glob("404.html")
             + glob.glob("guides/*.html") + glob.glob("drafts/*.html"))
    if not pages:
        sys.exit("no pages found — wrong directory?")
    failures = 0

    for page in pages:
        src = open(page, encoding="utf-8").read()

        checker = BalanceChecker()
        checker.feed(src)
        for err in checker.errors[:3]:
            print(f"{page}: {err}"); failures += 1
        if checker.stack:
            print(f"{page}: unclosed tags {checker.stack}"); failures += 1

        for m in re.finditer(r'<script type="application/ld\+json">(.*?)</script>', src, re.S):
            try:
                json.loads(m.group(1))
            except json.JSONDecodeError as e:
                print(f"{page}: invalid JSON-LD: {e}"); failures += 1

        base = "guides" if page.startswith("drafts/") else os.path.dirname(page)
        for m in re.finditer(r'(?:href|src)="([^"]+)"', src):
            url = m.group(1)
            if url.startswith(("http", "#", "mailto", "tel", "/")):
                continue
            target = os.path.normpath(os.path.join(base, url.split("#")[0]))
            if not os.path.exists(target) and \
               not os.path.exists(target.replace("guides/", "drafts/", 1)):
                print(f"{page}: broken ref {url}"); failures += 1

        if page != "404.html":
            for tag, pat in [("title", r"<title>"), ("meta description", r'name="description"'),
                             ("canonical", r'rel="canonical"')]:
                if not re.search(pat, src):
                    print(f"{page}: missing {tag}"); failures += 1

    if os.path.exists("drafts/queue.json"):
        try:
            q = json.load(open("drafts/queue.json"))
            idx = open("index.html", encoding="utf-8").read()
            for entry in q.get("queue", []):
                if not os.path.exists(f"drafts/{entry['slug']}.html"):
                    print(f"queue.json: missing draft {entry['slug']}"); failures += 1
                if f"<!-- CAT:{entry['category']} -->" not in idx:
                    print(f"queue.json: no CAT:{entry['category']} marker in index.html"); failures += 1
        except (json.JSONDecodeError, KeyError) as e:
            print(f"queue.json: {e}"); failures += 1

    print(f"\nchecked {len(pages)} pages: " + ("all OK" if not failures else f"{failures} FAILURES"))
    sys.exit(1 if failures else 0)


if __name__ == "__main__":
    main()
