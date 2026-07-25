#!/usr/bin/env bash
# Run fastlane snapshot for the app described by screenshots/config.json.
#
# Usage (from the app repo root, or pass --app-dir):
#   run_screenshots.sh                         # all screens, all configured languages
#   run_screenshots.sh --languages en-US       # one language (fast design iteration)
#   run_screenshots.sh --screens home,compose  # subset of screens (via env, see note)
#   run_screenshots.sh --app-dir /path/to/app
#
# Requires: bundler + fastlane (`bundle exec fastlane snapshot init` done once), and a
# Snapfile (from assets/Snapfile.template) in <app>/fastlane/.
set -euo pipefail

APP_DIR="."
LANGUAGES=""
SCREENS=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --app-dir)   APP_DIR="$2"; shift 2 ;;
    --languages) LANGUAGES="$2"; shift 2 ;;
    --screens)   SCREENS="$2"; shift 2 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

cd "$APP_DIR"
CONFIG="screenshots/config.json"
[[ -f "$CONFIG" ]] || { echo "missing $CONFIG (create from assets/config.example.json)" >&2; exit 1; }

# fastlane must be available
command -v bundle >/dev/null || { echo "bundler not found; add fastlane to the app's Gemfile" >&2; exit 1; }

ARGS=()
if [[ -n "$LANGUAGES" ]]; then
  # override Snapfile languages for a quick pass
  ARGS+=("languages:[$(echo "$LANGUAGES" | sed 's/,/","/g; s/^/"/; s/$/"/')]")
fi

# NOTE: limiting to specific screens is done in the UITest, not fastlane. For a fast subset,
# temporarily comment out capture() lines, or gate them on an env var read in the test:
#   if ProcessInfo.processInfo.environment["SCREENSHOT_ONLY"]?.contains("home") ?? true { capture(...) }
if [[ -n "$SCREENS" ]]; then
  export SCREENSHOT_ONLY="$SCREENS"
  echo "note: set SCREENSHOT_ONLY=$SCREENS — ensure the UITest honors it (see comment)."
fi

echo "==> fastlane snapshot ${ARGS[*]:-（all）}"
bundle exec fastlane snapshot "${ARGS[@]}"

echo "==> done. Gallery: $(pwd)/fastlane/screenshots/screenshots.html"
