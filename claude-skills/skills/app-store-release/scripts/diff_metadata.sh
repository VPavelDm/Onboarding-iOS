#!/bin/bash
# Downloads the live ASC metadata to a scratch dir and diffs it against the repo's
# fastlane/metadata, normalizing the trailing newlines deliver adds on download.
# Understands deliver's default/ fallback: a per-locale file missing locally is
# compared against metadata/default/<file> before being reported.
#
# Run from the iOS project root (dir with Gemfile + fastlane/):
#   scripts/diff_metadata.sh <scratch_dir>
#
# Output: one line per difference (DIFF/ONLY-ASC/ONLY-LOCAL), or "CLEAN".
# Exit code 0 = clean, 1 = differences found.
set -euo pipefail

SCRATCH="${1:?usage: diff_metadata.sh <scratch_dir>}"
LOCAL="fastlane/metadata"
[ -d "$LOCAL" ] || { echo "ERROR: $LOCAL not found — run from the iOS project root"; exit 2; }

export LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 FASTLANE_SKIP_UPDATE_CHECK=1
rm -rf "$SCRATCH/asc_meta"
bundle exec fastlane deliver download_metadata \
  --api_key_path "${ASC_API_KEY_PATH:-$HOME/.fastlane/key.json}" \
  --metadata_path "$SCRATCH/asc_meta" --force >/dev/null 2>&1 \
  || { echo "ERROR: download_metadata failed — rerun without output redirect to see why"; exit 2; }

norm() { sed -e 's/[[:space:]]*$//' "$1" 2>/dev/null | awk 'NF||p{p=1;print}'; }

dirty=0
cd "$SCRATCH/asc_meta"
for f in $(find . -name "*.txt" | sort); do
  rel="${f#./}"
  lf="$OLDPWD/$LOCAL/$rel"
  # deliver downloads locale-invariant URLs into every locale dir; locally they live once in default/
  if [ ! -f "$lf" ]; then
    base=$(basename "$rel")
    fallback="$OLDPWD/$LOCAL/default/$base"
    if [ -f "$fallback" ]; then lf="$fallback"; else
      [ -s "$f" ] && grep -q '[^[:space:]]' "$f" && { echo "ONLY-ASC: $rel"; dirty=1; }
      continue
    fi
  fi
  [ "$(norm "$f")" != "$(norm "$lf")" ] && { echo "DIFF: $rel"; dirty=1; }
done
cd "$OLDPWD"
for f in $(cd "$LOCAL" && find . -name "*.txt" -not -path "./default/*" -not -path "./review_information/*" | sort); do
  rel="${f#./}"
  if [ ! -f "$SCRATCH/asc_meta/$rel" ] && [ -s "$LOCAL/$rel" ] && grep -q '[^[:space:]]' "$LOCAL/$rel"; then
    echo "ONLY-LOCAL: $rel"; dirty=1
  fi
done

[ $dirty -eq 0 ] && echo "CLEAN"
exit $dirty
