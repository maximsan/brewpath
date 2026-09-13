#!/usr/bin/env bash
#
# clean_build_caches.sh — reclaim the disk this project's builds eat.
#
# WHEN TO RUN THIS
#   When the machine is low on space, or a command fails with "no space left on
#   device". An iOS Flutter project generates gigabytes per build and never
#   reclaims them: Xcode keeps a DerivedData tree per build configuration, and
#   every git worktree grows its own `build/`. Six worktrees is ~15 GB.
#
#   Everything this deletes is regenerated on the next build. Nothing here is
#   source, git data, an Xcode Archive, or a package cache — the first three
#   cannot be rebuilt, and wiping the last costs a full re-download for no
#   space worth having.
#
#   It reports and exits by default. Deleting takes --apply, so the first run
#   can never surprise you.
#
# USAGE
#   ./tool/clean_build_caches.sh                     # report only
#   ./tool/clean_build_caches.sh --apply             # Xcode caches, dead simulators
#   ./tool/clean_build_caches.sh --apply --worktrees # also every build/
#
#   ⚠️ --worktrees forces a full rebuild for anyone working in one. Leave it off
#   while another session is mid-build.
#
set -euo pipefail

apply=0
worktrees=0
for arg in "$@"; do
  case "$arg" in
    --apply)     apply=1 ;;
    --worktrees) worktrees=1 ;;
    *)
      echo "usage: $(basename "$0") [--apply] [--worktrees]" >&2
      exit 2
      ;;
  esac
done

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# The checkout that owns the worktrees, which is not $PROJECT_ROOT when this
# runs from inside one: `--git-common-dir` points at the main clone's .git
# either way, and the worktrees hang off its parent.
MAIN_CHECKOUT="$(cd "$PROJECT_ROOT" && cd "$(git rev-parse --git-common-dir)/.." && pwd)"

DERIVED_DATA="$HOME/Library/Developer/Xcode/DerivedData"
DEVICE_SUPPORT="$HOME/Library/Developer/Xcode/iOS DeviceSupport"

free_space() { df -h /System/Volumes/Data | awk 'NR==2 {print $4}'; }

report() {
  [ -d "$1" ] || return 0
  printf '  %-16s %7s  %s\n' "$2" "$(du -sh "$1" 2>/dev/null | cut -f1)" "$1"
}

# An allow-list of the four things this script may delete, so a bad path stops
# the run rather than taking something that cannot be rebuilt — an Archive, say.
safe_rm() {
  local target="$1"
  [ -n "$target" ] && [ -d "$target" ] || return 0
  case "$target" in
    "$DERIVED_DATA" | "$DEVICE_SUPPORT" | "$MAIN_CHECKOUT"/build | "$MAIN_CHECKOUT"/*/build) ;;
    *)
      echo "  REFUSED — outside the allowed paths: $target" >&2
      return 1
      ;;
  esac
  rm -rf -- "$target"
  echo "  removed  $target"
}

build_dirs() {
  local dir
  for dir in "$MAIN_CHECKOUT"/build "$MAIN_CHECKOUT"/.claude/worktrees/*/build; do
    [ -d "$dir" ] && echo "$dir"
  done
  return 0
}

echo "==> Checkout: $MAIN_CHECKOUT"
echo "==> Free now: $(free_space)"
echo
echo "Xcode caches — rebuilt on demand:"
report "$DERIVED_DATA"   "DerivedData"
report "$DEVICE_SUPPORT" "DeviceSupport"
echo
echo "Flutter build output — needs --worktrees:"
while IFS= read -r dir; do report "$dir" "build"; done < <(build_dirs)

if [ "$apply" -eq 0 ]; then
  echo
  echo "==> Report only. Re-run with --apply to delete."
  exit 0
fi

echo
echo "==> [1/3] Xcode DerivedData"
safe_rm "$DERIVED_DATA"

echo "==> [2/3] iOS DeviceSupport — symbols, re-fetched when a device connects"
safe_rm "$DEVICE_SUPPORT"

# Only devices whose runtime is already gone. Never `simctl erase`, which would
# throw away installed apps and their data on simulators still in use.
echo "==> [3/3] Simulator devices with no runtime"
xcrun simctl delete unavailable || true

if [ "$worktrees" -eq 1 ]; then
  echo "==> Build output in every worktree"
  while IFS= read -r dir; do safe_rm "$dir"; done < <(build_dirs)
fi

echo
echo "==> Free after: $(free_space)"
