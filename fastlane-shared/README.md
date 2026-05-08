# Shared fastlane lanes

Reusable fastlane lanes for VPavelDm iOS apps. One source of truth for App Store
metadata pushes, release submission, and per-territory subscription pricing.

## Lanes

- `push_metadata` — push App Store Connect metadata only (no binary, no screenshots)
- `submit_release` — submit latest build for review, tag the release, bump marketing version, push
- `update_subscription_prices` — interactive flow to update display names and per-territory subscription prices, snapped to psychological endpoints (`X-1.99` / `X.49` / `X.99`)

Run `bundle exec fastlane lanes` from a consuming project for full descriptions.

## Setting up a new iOS project

Assumes:

- This repo (`onboarding-ios`) is cloned at `~/Developer/Onboarding/onboarding-ios/`
- `~/.fastlane/key.json` exists — App Store Connect API key for the team. If the new app is in a different team, set `ASC_API_KEY_PATH=/path/to/key.json` (per-shell or in `~/.zshrc`)

### 1. Install fastlane in the project

```sh
cd ~/Developer/MyApp
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

### 4. Verify

```sh
bundle exec fastlane lanes
```

Should list `push_metadata`, `submit_release`, `update_subscription_prices`.

## Per-lane requirements

| Lane | Requires |
|---|---|
| `push_metadata` | `fastlane/metadata/` populated (run `bundle exec fastlane deliver init` once to scaffold) |
| `submit_release` | Exactly one `.xcodeproj` directly in project root (or pass `xcodeproj:` and `target:` explicitly). A reviewable build already uploaded to App Store Connect |
| `update_subscription_prices` | Subscription created in App Store Connect with at least USA pricing set |

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
