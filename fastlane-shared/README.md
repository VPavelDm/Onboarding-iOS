# Shared fastlane lanes

Reusable fastlane lanes for VPavelDm iOS apps. One source of truth for App Store
metadata pushes, release submission, and per-territory subscription pricing.

## Lanes

- `push_metadata` — push App Store Connect metadata only (no binary, no screenshots)
- `submit_release` — submit latest build for review, tag the release, bump marketing version, push
- `update_subscription_prices` — interactive flow to update display names and per-territory subscription prices, snapped to psychological endpoints (`X-1.99` / `X.49` / `X.99`)

Run `bundle exec fastlane lanes` from a consuming project for full descriptions.

## Setting up a new iOS project

Prereqs (verify before starting):

- This repo (`onboarding-ios`) is cloned at `~/Developer/Onboarding/onboarding-ios/`
- `~/.fastlane/key.json` exists — App Store Connect API key for the team. If the new app is in a different team, set `ASC_API_KEY_PATH=/path/to/key.json` (per-shell or in `~/.zshrc`)
- A build for the version you want to ship is already uploaded to ASC and finished processing

**Critical layout rule:** `Gemfile`, `fastlane/`, and the `.xcodeproj` must all live in the same directory, and that directory must be inside the git repo. The `submit_release` lane auto-detects the xcodeproj as `../*.xcodeproj` from the fastlane dir, and runs `ensure_git_status_clean` (so untracked files outside the repo break it). Run `git rev-parse --show-toplevel` first if unsure where the repo root is.

### 1. Install fastlane in the project

Run from the directory containing `.xcodeproj` (inside the git repo):

```sh
cd ~/Developer/MyApp/MyApp   # the dir that contains MyApp.xcodeproj
bundle init
echo 'gem "fastlane"' >> Gemfile
bundle install
```

### 2. Create `fastlane/Appfile`

```ruby
app_identifier("com.yourcompany.YourApp")
apple_id("you@example.com")
```

### 3. Create `fastlane/Fastfile`

```ruby
shared_path = ENV["SHARED_FASTLANE_PATH"] ||
              "#{ENV['HOME']}/Developer/Onboarding/onboarding-ios/fastlane-shared"

UI.user_error!("Shared fastlane not found at #{shared_path}. Clone onboarding-ios or set SHARED_FASTLANE_PATH.") unless File.directory?(shared_path)

import "#{shared_path}/Fastfile"
```

### 4. Update `.gitignore`

Append to the project's `.gitignore` so runtime artifacts don't get committed:

```
fastlane/report.xml
fastlane/Preview.html
fastlane/screenshots
fastlane/test_output
```

### 5. Scaffold App Store metadata

```sh
bundle exec fastlane deliver init --api_key_path ~/.fastlane/key.json --app_identifier com.yourcompany.YourApp
```

This downloads existing ASC metadata into `fastlane/metadata/` and creates `fastlane/Deliverfile`. **Then fill in `fastlane/metadata/<locale>/release_notes.txt`** for the version you're about to ship — ASC rejects review submissions with an empty `whatsNew`. Generic fallback: `Bug fixes and performance improvements.`

### 6. Commit everything

```sh
git add Gemfile Gemfile.lock .gitignore fastlane/Appfile fastlane/Fastfile fastlane/Deliverfile fastlane/metadata/
git commit -m "Set up fastlane with shared lanes from onboarding-ios"
```

`submit_release` runs `ensure_git_status_clean` first — anything untracked aborts the lane.

### 7. Verify

```sh
bundle exec fastlane lanes
```

Should list `push_metadata`, `submit_release`, `update_subscription_prices`.

## Per-lane requirements

| Lane | Requires |
|---|---|
| `push_metadata` | `fastlane/metadata/` populated (step 5 above) |
| `submit_release` | Steps 1–6 complete. Exactly one `.xcodeproj` next to the fastlane dir (or pass `xcodeproj:` and `target:` explicitly). A reviewable build already uploaded to ASC. Non-empty `release_notes.txt` for the version being shipped |
| `update_subscription_prices` | Subscription created in ASC with at least USA pricing set |

## Environment variables

| Var | Default | Purpose |
|---|---|---|
| `SHARED_FASTLANE_PATH` | `~/Developer/Onboarding/onboarding-ios/fastlane-shared` | Override if `onboarding-ios` is cloned elsewhere |
| `ASC_API_KEY_PATH` | `~/.fastlane/key.json` | Override for projects in a different ASC team |

## Layout

```
fastlane-shared/
├── Fastfile              # Lane definitions
├── README.md             # This file
└── pricing/
    ├── price_updater.rb  # AppStorePricing module — ASC API client + tier rounding
    └── indexes/
        └── ppp.json      # World Bank PPP multipliers (refresh periodically)
```
