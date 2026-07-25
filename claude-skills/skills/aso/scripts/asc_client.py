#!/usr/bin/env python3
"""Minimal App Store Connect API client (ES256 JWT auth).

Env: ASC_KEY_ID, ASC_ISSUER_ID, ASC_KEY_PATH (see references/asc-api-setup.md).
Deps: pip3 install pyjwt cryptography

Usage:
  python3 asc_client.py get "/v1/apps?filter[bundleId]=com.example"   # raw GET, prints JSON
  python3 asc_client.py analytics <asc-app-numeric-id>                # report-request status

The analytics flow is asynchronous by design: an ONGOING analyticsReportRequest makes
Apple generate daily/weekly reports continuously; the monthly run just lists instances
and downloads segment TSVs. `analytics` creates the ONGOING request if missing and
prints available reports + instance URLs; download segments with `get` on the printed
paths (segment URLs are pre-signed — fetch with plain curl, no auth header).
"""
import json
import os
import sys
import time
import urllib.request

BASE = "https://api.appstoreconnect.apple.com"


def token():
    try:
        import jwt
    except ImportError:
        sys.exit("missing deps: pip3 install pyjwt cryptography")
    key_id, issuer = os.environ.get("ASC_KEY_ID"), os.environ.get("ASC_ISSUER_ID")
    key_path = os.path.expanduser(os.environ.get("ASC_KEY_PATH", ""))
    if not (key_id and issuer and os.path.exists(key_path)):
        sys.exit("ASC_KEY_ID / ASC_ISSUER_ID / ASC_KEY_PATH not configured "
                 "(see references/asc-api-setup.md)")
    now = int(time.time())
    return jwt.encode(
        {"iss": issuer, "iat": now, "exp": now + 1200, "aud": "appstoreconnect-v1"},
        open(key_path).read(), algorithm="ES256", headers={"kid": key_id})


def get(path):
    req = urllib.request.Request(
        BASE + path if path.startswith("/") else path,
        headers={"Authorization": f"Bearer {token()}"})
    with urllib.request.urlopen(req, timeout=60) as r:
        return json.load(r)


def post(path, body):
    req = urllib.request.Request(
        BASE + path, data=json.dumps(body).encode(),
        headers={"Authorization": f"Bearer {token()}",
                 "Content-Type": "application/json"}, method="POST")
    with urllib.request.urlopen(req, timeout=60) as r:
        return json.load(r)


def analytics(app_id):
    reqs = get(f"/v1/apps/{app_id}/analyticsReportRequests")["data"]
    ongoing = [r for r in reqs if r["attributes"]["accessType"] == "ONGOING"]
    if not ongoing:
        print("no ONGOING request — creating one (reports appear within ~48h)")
        post("/v1/analyticsReportRequests", {"data": {
            "type": "analyticsReportRequests",
            "attributes": {"accessType": "ONGOING"},
            "relationships": {"app": {"data": {"type": "apps", "id": str(app_id)}}}}})
        return
    req_id = ongoing[0]["id"]
    reports = get(f"/v1/analyticsReportRequests/{req_id}/reports?limit=50")["data"]
    for rep in reports:
        name = rep["attributes"]["name"]
        if name not in ("App Store Discovery and Engagement", "App Downloads"):
            continue
        print(f"\n== {name} ({rep['attributes']['category']}) ==")
        insts = get(f"/v1/analyticsReports/{rep['id']}/instances?limit=5")["data"]
        for inst in insts:
            a = inst["attributes"]
            print(f"  {a['granularity']} {a['processingDate']}: "
                  f"segments -> /v1/analyticsReportInstances/{inst['id']}/segments")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    if sys.argv[1] == "get":
        json.dump(get(sys.argv[2]), sys.stdout, indent=2)
        print()
    elif sys.argv[1] == "analytics":
        analytics(sys.argv[2])
    else:
        sys.exit(__doc__)
