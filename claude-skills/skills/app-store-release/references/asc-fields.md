# ASC field → fastlane map

Everything `deliver` reads from `fastlane/metadata/`. "Required" = App Review will
block or reject without it. Char limits are enforced by ASC — count before writing.

## Non-localized (files directly in `metadata/`)

| Field | File | Required | Notes |
|---|---|---|---|
| Copyright | `copyright.txt` | yes | `<year> <legal holder>`, e.g. `2026 Jane Doe` |
| Primary category | `primary_category.txt` | yes | ASC enum, e.g. `UTILITIES`, `LIFESTYLE`, `PRODUCTIVITY` |
| Secondary category | `secondary_category.txt` | no | often worth setting — second browse surface |
| Subcategories | `primary_first_sub_category.txt` etc. | only for GAMES/STICKERS | |

## Localized (per-locale dirs, `metadata/default/` as fallback)

`default/` values apply to every locale that lacks its own file — put locale-invariant
values (URLs) there once instead of copying into 18 dirs.

| Field | File | Limit | Required | Notes |
|---|---|---|---|---|
| Description | `description.txt` | 4000 | yes | conversion copy; not search-indexed |
| Promotional text | `promotional_text.txt` | 170 | no | editable WITHOUT a release |
| Release notes | `release_notes.txt` | 4000 | updates only | first release: omit |
| Support URL | `support_url.txt` | — | yes | must resolve; a page, not a mailto |
| Marketing URL | `marketing_url.txt` | — | no | the app's website |
| Privacy policy URL | `privacy_url.txt` | — | yes | app info level; per-locale possible, usually one URL in `default/` |
| Title / subtitle / keywords | `name.txt` / `subtitle.txt` / `keywords.txt` | 30/30/100 | yes | **owned by `keyword-research` — never write from this skill** |

## Review information (`metadata/review_information/`)

| Field | File | Notes |
|---|---|---|
| Contact first name | `first_name.txt` | required |
| Contact last name | `last_name.txt` | required |
| Phone | `phone_number.txt` | with country code, e.g. `+49...` |
| Email | `email_address.txt` | required |
| Demo user | `demo_user.txt` | required if the app has any login |
| Demo password | `demo_password.txt` | must work on the LIVE backend |
| Notes | `notes.txt` | tell the reviewer anything non-obvious (test flow, feature flags) |

## Deliverfile options (not metadata files)

| Concern | Option | Notes |
|---|---|---|
| Price | `price_tier` | `0` = free |
| Release timing | `automatic_release` | false = manual release after approval (safe default) |
| Phased release | `phased_release` | 7-day gradual rollout; only meaningful with an existing install base |
| Export compliance | `submission_information: { export_compliance_uses_encryption: ... }` | prefer `ITSAppUsesNonExemptEncryption` in Info.plist — answers it permanently |
| Third-party content | `submission_information: { content_rights_contains_third_party_content: ... }` | |
| Age rating | `app_rating_config_path` | JSON schema varies by fastlane version — fetch current deliver docs before writing |

## Separate actions (not part of deliver)

- **App privacy nutrition labels**: effectively NOT automatable here. The relevant
  actions are `download_app_privacy_details_from_app_store` /
  `upload_app_privacy_details_to_app_store` (there is no `fetch_app_privacy_details`),
  and both require Apple-ID web-session auth (interactive 2FA) — they do not accept an
  API key, and the raw ASC API exposes no privacy-label endpoints to API keys either.
  Don't burn time probing; send the user to the ASC UI with a prepared list of what
  the app collects. A live app already has published labels.
- **Precheck**: runs automatically inside every `deliver` upload — a green
  `push_metadata` already covers broken URLs, placeholder text, competitor-brand
  mentions. Only run standalone `fastlane precheck` when checking without uploading;
  with API-key auth pass `--include_in_app_purchases false` (precheck can't inspect
  IAPs via the API key and errors out otherwise). Not a guarantee of approval.

## Spaceship notes (fastlane ≥2.23x) — known-good calls only

The Spaceship API surface is littered with renamed/removed methods; these are verified
working, everything else adjacent probably isn't. `scripts/asc_state.rb` wraps all of
them — prefer running it over writing probes.

| Task | Working call | Dead ends (don't try) |
|---|---|---|
| Find app | `Spaceship::ConnectAPI::App.find(bundle_id)` | |
| Live / edit version | `app.get_live_app_store_version` / `app.get_edit_app_store_version` | |
| Rename draft version | `edit.update(attributes: { versionString: "1.5" })` | |
| Selected build | `edit.build` | |
| Recent builds | `app.get_builds(sort: "-uploadedDate", includes: "preReleaseVersion")` — **`limit:` is ignored, pages everything; slice with `.first(n)`** | |
| Pending review submissions | `app.get_review_submissions(filter: { "platform" => "IOS" })` | `Spaceship::ConnectAPI::ReviewSubmission.all` (no such method) |
| Age rating | `app.fetch_edit_app_info` → `info.fetch_age_rating_declaration`; read fields via `instance_variables` (no `.attributes`) | `version.fetch_age_rating_declaration` (removed: ASC API 1.3 moved it to AppInfo) |
| Privacy labels | — none with API key | `apps/{id}/dataUsages`, `dataUsagePublishState`, `Spaceship::ConnectAPI.get`, `AppStoreConnect.client` |

## Operational cautions

- `deliver download_metadata` without `--metadata_path` **overwrites the repo's
  metadata dir** — always download to a scratch path.
- Downloaded files end with a trailing newline; locally written ones may not. Diff
  content, not bytes, when verifying.
- Metadata uploads land in the app's *editable version* drafts. Name/subtitle/keywords
  / description / release notes ship with the next release; promotional text and
  review information apply without one.
- ASC requires an editable (e.g. "Prepare for Submission") version to exist for
  version-level fields; create it in ASC or via `deliver` if only a released version
  exists.
