---
name: app-store-release
description: Fill in everything App Store Connect needs before an iOS app can be released — support/marketing/privacy-policy URLs, description, promotional text, categories, copyright, age rating, App Review contact info & demo account, app privacy (nutrition labels), export compliance, pricing and release options — plus the What's New section, written from the actual git changes since the last release (propose English, get approval, then translate into every locale). Audits what's missing, derives what it can from the repo and the live listing, and asks the user targeted questions for the rest (e.g. the privacy policy link). Use this skill whenever the user wants to release or submit an app, prepare for App Review, complete the store listing, fix ASC release blockers, fill in App Store Connect fields like support URL or privacy policy, or write/update the What's New release notes. Does NOT touch title/subtitle/keywords (sibling `keyword-research` skill owns those) or screenshots (`app-screenshots`).
---

# App Store Release Metadata

Goal: every App Store Connect field an app needs before "Submit for Review" is filled —
with real values, not placeholders — and uploaded as ASC drafts. The skill stops at
"everything filled, verified, ready to submit": submission itself is the user's click
(or their release lane, or the `release` skill), never yours.

Division of labor: title/subtitle/keywords belong to `keyword-research`; screenshots to
`app-screenshots` / `app-screenshots-captions`; the marketing site (which can HOST the
privacy policy and support pages this skill needs URLs for) to `app-marketing-site`;
the end-to-end submit flow to `release` (which calls this skill for the metadata part).
Never write name.txt, subtitle.txt, or keywords.txt from this skill.

## Step 0 — Environment (do this first, exactly)

Every fastlane/Spaceship invocation in this skill needs this prelude or it fails in
confusing ways (deliver dies right after its own update notice when the locale isn't
UTF-8, and the update notice buries real output):

```bash
export LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 FASTLANE_SKIP_UPDATE_CHECK=1
```

- Always `bundle exec fastlane` / `bundle exec ruby` from the iOS project root (the
  dir with the Gemfile). Global fastlane installs rot; the Gemfile one is pinned.
  If bundle exec fails with `GemNotFound`, run `bundle install` once and retry.
- API key: `ENV["ASC_API_KEY_PATH"]` or `~/.fastlane/key.json` (the fastlane-shared
  convention). The bundled scripts default to the same path.
- Projects in this ecosystem import a shared Fastfile
  (`~/Developer/Onboarding/onboarding-ios/fastlane-shared`) that defines
  `push_metadata` (metadata-only deliver) — prefer it over hand-rolled deliver calls.

## Step 1 — Audit (fast path vs full)

Run these two in parallel — they're independent:

1. `bundle exec ruby <skill>/scripts/asc_state.rb` (from the project root) — prints
   app, live + edit version/state, selected build, last builds, pending review
   submissions, age rating. One shot; don't hand-write Spaceship probes, the API
   surface is full of dead ends (see references/asc-fields.md § Spaceship notes).
2. `<skill>/scripts/diff_metadata.sh <scratch_dir>` — downloads live ASC metadata to
   scratch and diffs against `fastlane/metadata/`, normalized, `default/`-fallback
   aware. Prints `CLEAN` or the exact drifted files.

**Fast path — the app is already live (`LIVE: x.y READY_FOR_SALE`) and the diff is
CLEAN or near-clean.** Everything static (URLs, categories, review info, age rating,
copyright, privacy labels) was already accepted by App Review at least once; do NOT
re-audit or re-interview it. The only work is:

- What's New for the new release (workflow below — this is the bulk of the task),
- optionally refresh `promotional_text.txt` if it advertises a shipped campaign,
- copyright year bump in January,
- check the audit output for the one thing that does drift: **edit version string ≠
  project MARKETING_VERSION** (grep `MARKETING_VERSION` in the pbxproj). If they
  differ, the release lane can't select the build later — fix with
  `bundle exec ruby <skill>/scripts/rename_edit_version.rb <project_version>`.

Then jump straight to Upload & verify. A recurring release should take minutes, not an
hour; the full audit below is for first releases and unknown apps.

**Full path — first release, or the audit found gaps/drift.** Read
`references/asc-fields.md` for the field → fastlane-file map, then derive from the
repo whatever can be derived: does the app have accounts/login (→ App Review needs a
demo account; anonymous-auth-only apps like Supabase `signInAnonymously` do NOT)?
What does the app collect — auth emails, photos, audio, location, analytics SDKs
(→ privacy label)? Is `ITSAppUsesNonExemptEncryption` set (pbxproj
`INFOPLIST_KEY_ITSAppUsesNonExemptEncryption` counts, → export compliance)? Copyright
`<current year> <holder>`. Categories from what the app does. Empty files count as
missing — a `review_information/` dir full of empty txt files is a gap, not a fill.

Present the gap table: field → current value (or "empty") → how it will be resolved
(derived / drafted / **needs the user**).

## Step 2 — Interview (full path only)

Ask for exactly the facts that live outside the repo, and nothing else. Use
AskUserQuestion, batch related fields (≤4 per round), and always show what the audit
found so the user answers in context. Typical rounds:

1. **URLs** — privacy policy URL (required), support URL (required), marketing URL
   (optional). If none hosted, offer the `app-marketing-site` skill and pause until
   the URLs exist — placeholder URLs get apps rejected.
2. **App Review info** — contact first/last name, phone (with country code), email;
   demo account credentials *only if the audit found a login flow* (the account must
   work on the live backend, App Review will use it).
3. **Business** — price (default: free), availability (default: all territories),
   release option (default: manual release after approval).

Anything the user answers with "whatever you think" gets the derived default, recorded
in the summary so they can veto it later.

## Step 3 — Draft the content fields (full path only)

Write these yourself from real app understanding — never lorem-ipsum, never a rehash of
the subtitle:

- **description.txt** (≤4000 chars) — for conversion, not search: first two lines carry
  the hook (they show above the fold), then concrete features, then who it's for.
- **promotional_text.txt** (≤170) — the one field editable *without* a release; use it
  for the current campaign, not a second subtitle.
- **release_notes.txt** (What's New) — has its own workflow, see below.
- Localize description and promotional text into every locale dir the app already
  has — transcreate with native phrasing per market. URLs and other locale-invariant
  values go once in `metadata/default/` (deliver's fallback dir).

## What's New (release notes) — propose → approve → translate

Required for every update (omit on the first release). Hard approval gate: it's the one
piece of store copy users read on every update.

1. **Find what changed:** `git log v<last-tag>..HEAD --oneline` (release lanes here tag
   `v<version>`; note the post-release version-bump commit marks the previous cycle's
   end). Read for user-visible effects; ignore refactors, CI, metadata commits. When
   commit subjects name features clearly, that's enough — don't read every diff.
2. **Propose the English version and STOP for approval.** Written for users, not a
   commit log: lead with the most exciting change, plain language, a few short lines
   or bullets. Purely internal release → propose the honest "Bug fixes and performance
   improvements". Do not translate or write any files until the user approves.
3. **Translate the approved text** into every locale dir including en-US. Before
   translating, read 2-3 existing `description.txt` locales to match established tone
   and terminology (German du vs Sie, what "capsule"/core nouns are called). Then
   write all locale files in one or two bash heredoc batches (`cat > <locale>/release_notes.txt <<'EOF'`)
   — one script for all locales beats 40 file-tool round-trips, and the Edit/Write
   tools require a prior read of each existing file anyway. Same batching for
   promotional_text.txt. Verify char limits in the same script
   (release notes ≤4000, promo ≤170): `python3 -c "print(len(open(f).read().strip()))"`.

Standalone entry point: "write the what's new" runs just this workflow plus Upload &
verify, skipping everything else.

## Step 4 — Structured configs (full path only)

- **review_information/** — one txt file per field (see the field map).
- **Age rating** — already-declared shows in the `asc_state.rb` output (all-NONE is
  right for most utility apps). Only when missing or wrong: a JSON referenced by
  Deliverfile `app_rating_config_path`; fetch the current schema from the deliver docs
  first — it changes across fastlane versions.
- **App privacy (nutrition labels)** — NOT manageable with API-key auth; see
  references/asc-fields.md § App privacy. Decision rule: app already live → labels are
  published; only flag to the user if this release starts collecting a NEW data type.
  First release → the user fills them once in the ASC UI; give them the list of what
  the audit found the app collects.
- **Deliverfile** — `price_tier`, `automatic_release` / `phased_release`,
  `submission_information`. If `ITSAppUsesNonExemptEncryption` is missing, prefer
  adding it to the project (permanent) over answering per-submission.

## Step 5 — Upload and verify

1. Show the user the complete change summary (every file/field, old → new). For the
   fast path this is: What's New text + promo text + any version rename.
2. On their explicit yes: `bundle exec fastlane push_metadata` (or plain `deliver` with
   `skip_binary_upload skip_screenshots skip_app_version_update force` if the lane is
   absent). Version-level fields (What's New) need an editable draft version to land
   on — when the audit showed `EDIT: none`, pass `app_version:<project_version>` so
   deliver creates the draft (only safe with no submission in review). Uploads fill
   ASC *drafts*; nothing is submitted for review. deliver runs precheck automatically
   as part of the push — a green push already covers broken URLs / placeholder text;
   do NOT run a separate precheck.
3. Verify: `scripts/diff_metadata.sh <scratch>` again → must print `CLEAN`. Report
   "verified in ASC" only after that.

## Step 6 — The human checklist

End with the release blockers this skill cannot do, checked against reality (don't
list what's already done — use the `asc_state.rb` output): a build uploaded and
**selected** on the version (`EDIT_BUILD: NONE SELECTED` is the tell), screenshots per
device class (point to `app-screenshots`), Paid Apps agreement for IAP apps (ASC UI
only), uncommitted metadata files (release lanes require a clean tree), and the final
Submit for Review click / release lane / `release` skill. If everything is green, say
so plainly: the app is one click from review.
