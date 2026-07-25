---
name: project-setup
description: Bootstrap a new iOS app project with the shared release infrastructure from onboarding-ios — Gemfile + fastlane, Appfile/Fastfile wired to fastlane-shared (push_metadata, submit_release lanes), Deliverfile, the fastlane/metadata skeleton, App Store Connect API key check, and Xcode Cloud pointers. Use this skill whenever the user starts a new iOS app, wants to set up or initialise fastlane, prepare a project for App Store releases, wire a project to fastlane-shared/onboarding-ios, or when the release / app-store-release skills report that the project has no fastlane setup or no submit_release lane.
---

# Project Setup (iOS release rails)

Goal: a fresh iOS app repo leaves this skill able to run `bundle exec fastlane
push_metadata` and `bundle exec fastlane submit_release` — the same rails every other
project uses. Shared logic stays in onboarding-ios (`fastlane-shared/`); the project
gets only thin, project-specific files. Don't copy lane code into the project — that's
the whole point of the shared repo.

## Step 1 — Preconditions (check all, report together)

1. **Xcode project**: exactly one `*.xcodeproj` in the repo (the shared Fastfile
   auto-detects it). Read `PRODUCT_BUNDLE_IDENTIFIER` from its pbxproj — that's the
   bundle id for the Appfile; don't ask the user for what the repo already knows.
2. **Shared repo**: `~/Developer/Onboarding/onboarding-ios/fastlane-shared/Fastfile`
   exists (or `$SHARED_FASTLANE_PATH` points somewhere valid). Missing → offer to
   clone `git@github.com:VPavelDm/Onboarding-iOS.git` into `~/Developer/Onboarding/`.
3. **API key**: `~/.fastlane/key.json` (or `$ASC_API_KEY_PATH`) exists. Missing → the
   user creates one in ASC → Users and Access → Integrations → App Store Connect API
   (team key, App Manager role), then saves it as fastlane's JSON format:
   `{"key_id": "...", "issuer_id": "...", "key": "-----BEGIN PRIVATE KEY-----\n..."}`.
   Never ask the user to paste the key into chat; they write the file themselves.
4. **App on ASC**: ask whether the app record already exists in App Store Connect
   (My Apps → +). Creating it needs a name + bundle id + SKU in the ASC UI — a
   one-time human step; the rails work either way, but `asc_state.rb` and metadata
   pushes only succeed once it exists.

## Step 2 — Write the project files

All idempotent — skip whatever already exists and matches.

**Gemfile** (repo root, next to the .xcodeproj):

```ruby
# frozen_string_literal: true

source "https://rubygems.org"

gem "fastlane"
```

**fastlane/Appfile** — apple_id is the ASC account email (ask once):

```ruby
app_identifier("<bundle id from pbxproj>")
apple_id("<ASC account email>")
```

**fastlane/Fastfile** — the standard stub, verbatim:

```ruby
shared_path = ENV["SHARED_FASTLANE_PATH"] ||
              "#{ENV['HOME']}/Developer/Onboarding/onboarding-ios/fastlane-shared"

UI.user_error!("Shared fastlane not found at #{shared_path}. Clone onboarding-ios or set SHARED_FASTLANE_PATH.") unless File.directory?(shared_path)

import "#{shared_path}/Fastfile"
```

**fastlane/Deliverfile** — create with just the doc-link comment (options only get
added when a project actually diverges from lane defaults).

**fastlane/metadata skeleton** — empty dirs and files, so `app-store-release` sees
them as explicit gaps rather than guessing at structure:

```
fastlane/metadata/
├── default/            (locale-invariant URLs land here later)
├── en-US/
├── review_information/
├── copyright.txt
├── primary_category.txt
└── secondary_category.txt
```

**.gitignore** — append fastlane's generated noise if missing:
`fastlane/report.xml`, `fastlane/README.md`, `fastlane/test_output`.

Then `bundle install` and verify with `bundle exec fastlane lanes` (UTF-8 prelude:
`export LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 FASTLANE_SKIP_UPDATE_CHECK=1`) — it must
list `push_metadata` and `submit_release`.

## Step 3 — Project settings the lanes assume

Check the pbxproj and surface what's off (fix on approval — these are one-line build
settings): `MARKETING_VERSION` set and identical across app targets;
`CURRENT_PROJECT_VERSION` present; `INFOPLIST_KEY_ITSAppUsesNonExemptEncryption = NO`
(answers export compliance permanently — only if the app really ships no custom
crypto).

## Step 4 — Xcode Cloud (human step, be specific)

`submit_release` triggers builds by pushing the `v<version>` tag. In Xcode: Report
navigator → Cloud → create a workflow with a **Tag Changes start condition, pattern
`v` (prefix match)**, an archive action, and TestFlight/App Store distribution. The
lane verifies a matching enabled start condition via the ASC API before pushing and
fails fast if none exists (the alternative it also accepts: a branch condition
matching `release/*`). A workflow watching `main` is optional — it gives per-merge
TestFlight builds at the cost of building every push; if you add one, note the lane
bumps main *after* submitting precisely so a main-watching workflow with auto-cancel
doesn't kill the release build.

## Step 5 — Hand off

Report what was created vs already present, plus the remaining human steps (ASC app
record, API key, Xcode Cloud workflow — only the ones actually missing). Point at the
follow-up skills: `keyword-research` (title/subtitle/keywords), `app-store-release`
(listing metadata), `app-screenshots`, and `release` when it's time to ship.
