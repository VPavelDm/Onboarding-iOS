---
name: release
description: Ship an iOS app release end to end — preflight the repo (uncommitted changes, branch, remote sync), reconcile the project version with the App Store Connect draft, prepare and upload store metadata + What's New via the app-store-release skill, then drive the project's submit_release lane (tag, Xcode Cloud build, build selection, Submit for Review, version bump) and monitor it to completion. Use this skill whenever the user wants to make/cut/ship a release, submit the app for review, "push to prod", release a new version, or resubmit after an App Review rejection. If the user only wants store listing fields or What's New text WITHOUT submitting, use the sibling app-store-release skill instead — this skill is for actually shipping.
---

# Release

Goal: from "make a release" to "submitted for review" in one guided pass, with exactly
three stops for the user: commit approval, What's New approval, and the final
submit confirmation. Everything else is deterministic — run it, don't ask.

This skill drives the `submit_release` lane from fastlane-shared, which already owns
tagging (`v<version>`), triggering Xcode Cloud, waiting for the build, selecting it,
submitting with automatic release, and bumping main to the next minor. Don't duplicate
any of that by hand; the skill's job is everything the lane assumes but doesn't check.
(No `submit_release` lane or no fastlane dir in the project? Run the sibling
`project-setup` skill first — it wires the project to fastlane-shared; never
reimplement the lane inline.)

Environment prelude for every fastlane/ruby call, from the iOS project root:

```bash
export LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 FASTLANE_SKIP_UPDATE_CHECK=1
```

`<asr>` below = the sibling `app-store-release` skill's directory (`../app-store-release`
relative to this skill).

## Step 1 — Preflight (parallel, ~1 minute)

Run these checks concurrently; collect ALL failures before talking to the user so they
get one consolidated preflight report, not a drip.

1. **Working tree**: `git status --porcelain`. Dirty tree → the lane's
   `ensure_git_status_clean` will abort later, so resolve it NOW: show the changed
   files, propose a commit message, and on approval commit and push. Untracked junk
   the user doesn't want committed belongs in .gitignore, not in the release.
2. **Branch**: `git rev-parse --abbrev-ref HEAD`.
   - `main` → normal release.
   - `release/vX.Y` → this is a RESUBMISSION: the lane will cancel the pending review
     submission, push fix commits, rebuild, resubmit, and open a backport PR to main.
     Confirm with the user that a resubmit is what they want.
   - anything else → stop; releases ship from main (merge first).
3. **Remote sync**: `git fetch origin && git rev-list --left-right --count HEAD...origin/<branch>`.
   Behind → pull first (the lane pushes without --force and fails loudly on
   divergence). Ahead-only is fine — the commit push in step 1 covers it.
4. **Versions**: project version from
   `grep MARKETING_VERSION *.xcodeproj/project.pbxproj | sort -u` (multiple different
   values across targets = a problem to surface), ASC state via
   `bundle exec ruby <asr>/scripts/asc_state.rb`. Interpret:
   - `REVIEW_SUBMISSION: ... WAITING_FOR_REVIEW/IN_REVIEW` on main → there's already a
     release in flight; stop and tell the user (resubmits happen from the release
     branch, not main).
   - `EDIT:` version ≠ project version → the lane won't find the build later; queue a
     rename via `bundle exec ruby <asr>/scripts/rename_edit_version.rb <project_version>`
     (run it in step 3, after the user has seen the plan).
   - `EDIT: none` → deliver will create the version during the metadata push; fine.
   - Tag `v<project_version>` already exists (`git tag -l`) on a different commit →
     surface it; the lane force-moves tags, which is only right if that's intended.

Report the preflight result compactly, fix what was approved, then move on.

## Step 2 — Store metadata + What's New

Follow the `app-store-release` skill (read `<asr>/SKILL.md`), which on an already-live
app takes its fast path: What's New from `git log v<last>..HEAD` (propose English →
**user approval gate** → transcreate into all locale dirs), optional promo-text
refresh, upload drafts via `push_metadata`, verify with `diff_metadata.sh` → CLEAN.

If this release has user-visible UI changes, mention (don't block) that screenshots
may be stale — `app-screenshots` is the follow-up skill for that.

Then commit the metadata files it wrote and push (one more approval if the user hasn't
already blanket-approved commits this session) — the lane needs a clean tree.

## Step 3 — Submit

One final explicit confirmation, because this is the irreversible-ish step: "This
tags v<version>, builds on Xcode Cloud, and submits to App Review with automatic
release — go?" On yes:

- Apply the queued version rename if any (step 1.4).
- Run `bundle exec fastlane submit_release` **in the background** (it sleeps 10
  minutes before even polling; total 15–25 min). Check the output every few minutes.
- Early sanity check (first ~30s of output): the tag and branch pushes succeeded and
  the lane reached "Sleeping 10 min before polling ASC". Then leave it alone.

## Step 4 — Report the outcome

On lane exit, read the tail of the output:

- **Success** looks like: build state VALID → "Successfully selected build" →
  "Successfully submitted the app for review!" → "Bump marketing version to X.Y" →
  pushed. Report: version submitted, build number, automatic release, main bumped.
- **Build FAILED/INVALID**: the lane aborts. Xcode Cloud build logs (App Store Connect
  → Xcode Cloud) have the compile error; fix, then re-run — from main it's idempotent
  up to the tag force-move.
- **Precheck/deliver rejection**: metadata issue; fix the file it names, re-run.
- **Nothing to submit / already submitted**: a pending submission existed (preflight
  step 1.4 should have caught this).

After a successful submit, remind the user of the one follow-up path they'll need if
App Review rejects: check out `release/v<version>`, fix, and re-run this skill (or the
lane) from that branch — it cancels the stuck submission and resubmits.
