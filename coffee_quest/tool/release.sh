#!/usr/bin/env bash
#
# release.sh — cut a Coffee Quest release.
#
# Performs the TestFlight/App Store release ritual in one step:
#   1. Bumps the version in coffee_quest/pubspec.yaml (always bumps the build
#      number; optionally bumps the semantic version).
#   2. Stamps the "## [Unreleased]" section of docs/CHANGELOG.md with the new
#      version and today's date, and opens a fresh empty Unreleased block.
#   3. (with --commit) commits both files and creates an annotated git tag.
#
# Usage:
#   tool/release.sh [patch|minor|major|X.Y.Z] [--commit] [--dry-run]
#
#   (no version arg)   bump build number only          1.0.0+1 -> 1.0.0+2
#   patch              bump patch + build              1.0.0+1 -> 1.0.1+2
#   minor              bump minor (reset patch) + build 1.0.0+1 -> 1.1.0+2
#   major              bump major (reset minor/patch)   1.0.0+1 -> 2.0.0+2
#   X.Y.Z              set explicit semver + build      ->      X.Y.Z+2
#
#   --dry-run          print what would change; write nothing
#   --commit           git add + commit + annotated tag after editing
#
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
PUBSPEC="$ROOT/coffee_quest/pubspec.yaml"
CHANGELOG="$ROOT/docs/CHANGELOG.md"

BUMP=""          # patch | minor | major | explicit X.Y.Z | "" (build only)
DRY_RUN=0
DO_COMMIT=0

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --commit)  DO_COMMIT=1 ;;
    patch|minor|major) BUMP="$arg" ;;
    [0-9]*.[0-9]*.[0-9]*) BUMP="$arg" ;;
    *) echo "error: unknown argument '$arg'" >&2; exit 1 ;;
  esac
done

[ -f "$PUBSPEC" ]   || { echo "error: $PUBSPEC not found" >&2; exit 1; }
[ -f "$CHANGELOG" ] || { echo "error: $CHANGELOG not found" >&2; exit 1; }

# --- Parse current version: "version: X.Y.Z+B" --------------------------------
CUR_LINE="$(grep -E '^version:' "$PUBSPEC" | head -1)"
CUR_VER="${CUR_LINE#version: }"
CUR_VER="${CUR_VER// /}"
SEMVER="${CUR_VER%%+*}"
BUILD="${CUR_VER##*+}"
IFS='.' read -r MA MI PA <<< "$SEMVER"

case "$BUMP" in
  "")            ;;                                  # semver unchanged
  patch)         PA=$((PA + 1)) ;;
  minor)         MI=$((MI + 1)); PA=0 ;;
  major)         MA=$((MA + 1)); MI=0; PA=0 ;;
  *)             IFS='.' read -r MA MI PA <<< "$BUMP" ;;  # explicit X.Y.Z
esac

NEW_SEMVER="$MA.$MI.$PA"
NEW_BUILD=$((BUILD + 1))
NEW_VER="$NEW_SEMVER+$NEW_BUILD"
DATE="$(date +%Y-%m-%d)"
TAG="v$NEW_VER"

# --- Warn if there is nothing in Unreleased to release ------------------------
UNREL_BODY="$(awk '/^## \[Unreleased\]/{f=1;next} /^## /{f=0} f' "$CHANGELOG" \
              | grep -E '^\s*-\s' || true)"
if [ -z "$UNREL_BODY" ]; then
  echo "warning: the [Unreleased] section has no entries (- bullets)."
  echo "         Run /changelog first, or this release will have an empty section."
fi

echo "Current version : $CUR_VER"
echo "New version     : $NEW_VER"
echo "Changelog stamp : ## [$NEW_VER] — $DATE"
echo "Git tag         : $TAG"
echo

if [ "$DRY_RUN" -eq 1 ]; then
  echo "[dry-run] no files changed."
  exit 0
fi

# --- 1. pubspec version -------------------------------------------------------
perl -pi -e "s/^version: .*/version: $NEW_VER/ if !\$done && /^version:/ && (\$done=1)" "$PUBSPEC"

# --- 2. changelog: rename Unreleased -> version, open a fresh Unreleased -------
NEWVER="$NEW_VER" DATE="$DATE" perl -0777 -pi -e '
  my $v = $ENV{NEWVER};
  my $d = $ENV{DATE};
  s/^## \[Unreleased\]\n/## [Unreleased]\n\n### Added\n\n### Changed\n\n### Fixed\n\n---\n\n## [$v] — $d\n/m;
' "$CHANGELOG"

echo "Updated $PUBSPEC and $CHANGELOG."

# --- 3. optional commit + tag -------------------------------------------------
if [ "$DO_COMMIT" -eq 1 ]; then
  git -C "$ROOT" add "$PUBSPEC" "$CHANGELOG"
  git -C "$ROOT" commit -m "chore(release): $NEW_VER"
  git -C "$ROOT" tag -a "$TAG" -m "Release $NEW_VER"
  echo "Committed and tagged $TAG."
else
  echo
  echo "Next steps (not done automatically — review first):"
  echo "  git add \"$PUBSPEC\" \"$CHANGELOG\""
  echo "  git commit -m \"chore(release): $NEW_VER\""
  echo "  git tag -a \"$TAG\" -m \"Release $NEW_VER\""
fi
