# App Store Connect API Setup

One-time, ~5 minutes of the user's clicks. Gives the skill real analytics (impressions,
conversion, search terms) instead of public-data inference.

## User steps (walk them through)

1. appstoreconnect.apple.com → **Users and Access → Integrations → App Store Connect API**
   (team keys). Requires Account Holder or Admin.
2. **Generate API Key**: name "aso-skill", role **Finance** is NOT needed — choose
   **Admin** for metadata write later, or **App Manager** (sufficient for analytics +
   metadata); download the `.p8` file (downloadable ONCE — store it safely, e.g.
   `~/.appstoreconnect/AuthKey_<KEYID>.p8`).
3. Note the **Key ID** (on the key row) and **Issuer ID** (top of the page).

## Environment (put in the shell profile or a project .env the user controls)

```
export ASC_KEY_ID=XXXXXXXXXX
export ASC_ISSUER_ID=xxxxxxxx-xxxx-...
export ASC_KEY_PATH=~/.appstoreconnect/AuthKey_XXXXXXXXXX.p8
```

Never commit the .p8 or print its contents. If credentials belong in the app repo's
tooling, reference the path only.

## Client

`scripts/asc_client.py` mints the ES256 JWT (needs `pip3 install pyjwt cryptography` —
tell the user if missing) and provides `get(path)` passthrough plus the analytics-report
dance. Useful endpoints:

- `GET /v1/apps` — resolve the app's ASC id from the bundle id
- `GET /v1/apps/{id}/appStoreVersions?limit=3` — versions and states
- `GET /v1/apps/{id}/appInfos` + `.../appInfoLocalizations` — live name/subtitle per locale
- Analytics: `POST /v1/analyticsReportRequests` (ONGOING), then poll
  `analyticsReports` → `instances` → `segments` → download TSVs. Asynchronous by design;
  ONGOING requests reuse Apple's daily generation, so the monthly run usually just reads.
  Relevant reports: "App Store Discovery and Engagement" (impressions, page views by
  source), "App Downloads" (units by source type).

## Degradation

No credentials → skip this file's phase, mark analytics "unavailable" in the report, and
diagnose from ranks/reviews/downloads proxies. Don't nag: offer setup once per app, then
respect the choice in config (`"asc": false`).
