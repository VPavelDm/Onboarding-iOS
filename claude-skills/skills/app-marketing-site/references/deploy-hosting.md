# Deploy & Hosting

## Recon before anything (answers most questions without asking)

```
dig +short NS <domain>          # where DNS lives (awsdns → Route 53, etc.)
dig +short <domain>             # A records → CDN? (CloudFront IPs, Cloudflare ranges)
curl -sI https://<domain>/      # what serves today; server/via headers reveal the stack
aws cloudfront list-distributions / aws s3 ls    # if AWS credentials exist
```

If working infra already exists (domain → CDN → bucket), use it — one sync command beats
a new account. Only propose new hosting when there's nothing.

## Pre-deploy safety checklist (do ALL of these before the first upload)

1. **List the target bucket/directory.** Shared buckets are common (legal PDFs, other
   apps' assets, images). Deploy alongside; NEVER `aws s3 sync --delete` a bucket you
   didn't fully inventory.
2. **Check `.well-known/apple-app-site-association`** on the domain AND `applinks:`
   entitlements in any related iOS project. If an AASA exists with a broad pattern
   (`"/" : "/*"`), it makes iOS open the app instead of the website for EVERY link on the
   domain. Find what paths the app actually consumes (search the app code for
   `onOpenURL` / share-link generators), scope the AASA to just those (e.g. `/tag/*`),
   re-upload with `content-type: application/json`. Never delete it if the app uses
   universal links — scope it. Note: devices cache the old AASA until app
   reinstall/Apple CDN refresh (~1 week).
3. **Check what else resolves on the domain** (subdomains on the same distribution,
   email DNS). Adding records is fine; don't repurpose existing ones.
4. **Existing site at the root?** If index.html already exists and you didn't create it,
   look at it and surface before overwriting.

## AWS S3 + CloudFront path (the deep path)

- Upload with cache headers: assets `public,max-age=604800` (or longer), HTML/CSS/xml/txt
  `public,max-age=600` so content updates propagate. Two-pass sync with `--exclude`.
- Set `DefaultRootObject: index.html` on the distribution (get-distribution-config →
  modify JSON → update-distribution with the ETag as --if-match). Note it only covers
  `/`, not subpaths — link full filenames.
- Custom error responses: 403→/404.html AND 404→/404.html (S3 origins return 403 for
  missing keys when ListBucket isn't granted).
- Invalidate after every deploy: `aws cloudfront create-invalidation --paths "/*"` (or
  targeted paths for single-article publishes).
- Content types: `sync` guesses by extension; files WITHOUT extensions (AASA!) need
  explicit `--content-type`.
- HTTPS: bare S3 website endpoints are HTTP-only — a custom-domain cert requires
  CloudFront (free ACM cert). HTTPS is non-negotiable for SEO and conversion.

## Fallback domain: <brand>.lyncil.com (no purchased domain)

Established pattern (here.lyncil.com is the reference deployment). Route 53 zone:
`lyncil.com` = `Z008708214O5D17MZRIR6`. Recipe:
1. ACM cert (MUST be us-east-1) for `<brand>.lyncil.com`, DNS validation — create the
   CNAME in the zone, issues in ~2–5 min.
2. Dedicated private S3 bucket `<brand>-lyncil-site` (eu-central-1); grant read to the
   shared CloudFront OAI `E25G50SAJ1657B` via bucket policy (no public access needed).
3. CloudFront distribution: alias `<brand>.lyncil.com`, that cert (sni-only, TLSv1.2_2021),
   S3 origin with the OAI, DefaultRootObject index.html, custom error responses
   403/404 → /404.html (404), redirect-to-https, compress on.
4. Route 53 A (+AAAA) ALIAS `<brand>.lyncil.com` → the distribution
   (CloudFront hosted zone id `Z2FDTNDATAQYW2`).
5. Upload with the standard cache headers, invalidate, verify from outside.

## Alternatives (when no existing infra)

- **Cloudflare Pages / Netlify**: free tier, git-push deploys, free TLS, custom domain
  via CNAME. Best default for new setups; point DNS at them.
- **GitHub Pages**: fine for flat sites; publishing a subfolder needs a small Actions
  workflow.
- All three replace the S3 steps; the site files and pipeline are host-agnostic (the
  publish script's upload step is the only host-specific part — adapt it).

## Post-deploy verification (always, from outside)

curl the root, one guide, one asset, robots.txt, llms.txt — expect 200s and correct
content-types. Then check anything that existed before still works (the PDFs, the AASA).

## Indexing setup (walk the user through; you do the CLI parts)

1. **Google Search Console** → Domain property → DNS TXT verification. If you have
   Route 53 access, create the TXT record yourself (check for existing TXT at the apex
   first — merging, not clobbering). Verify → submit sitemap. "Couldn't fetch" right
   after submission is a not-crawled-yet placeholder, not an error — confirm the sitemap
   serves 200 with a Googlebot UA and tell the user to wait. Optional accelerator: URL
   Inspection → Request indexing for the homepage.
2. **Bing Webmaster Tools** → "Import from Google Search Console" (no separate
   verification) → if sitemap count shows 0 after import, submit the sitemap URL manually.
   This is the ChatGPT-search index — frame it that way for the user.
