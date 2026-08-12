#!/usr/bin/env bash
#
# Fails when a branch changes the product without recording it in
# docs/CHANGELOG.md.
#
# The changelog only stays current if something notices when it doesn't. The
# /changelog skill drafts entries well, but it only runs when someone remembers
# to run it — and a two-month backlog accumulated on main precisely because
# nobody did (see the v1.0.0+3 → Aug 2026 gap, backfilled in #52).
#
# Usage:  tool/check_changelog.sh [base-ref]     # default: origin/main
#
# CI passes the pull request's base SHA. Locally, run it bare before opening a
# PR.
set -euo pipefail

base_ref="${1:-origin/main}"
changelog='docs/CHANGELOG.md'

if ! git rev-parse --verify --quiet "$base_ref" >/dev/null; then
  echo "✗ base ref '$base_ref' does not resolve. Fetch it first, or pass one."
  exit 2
fi

# Three-dot: compare against the merge base, so commits that landed on the base
# after this branch started are not counted as this branch's changes.
changed=$(git diff --name-only "$base_ref...HEAD")

# What counts as a product change. Deliberately narrower than "everything":
#   - generated Dart is codegen output, not a decision anyone made;
#   - test/ and docs/ carry no user- or developer-visible behaviour on their own;
#   - ios/ churns on plugin adds, which would fire this check on nothing.
product=$(printf '%s\n' "$changed" \
  | grep -E '^(lib/|assets/content/|pubspec\.yaml$)' \
  | grep -vE '\.(g|freezed)\.dart$' \
  || true)

if [ -z "$product" ]; then
  echo "✓ no product changes against $base_ref — changelog entry not required"
  exit 0
fi

fail() {
  echo "✗ $1"
  echo
  echo "  Product files changed:"
  printf '%s\n' "$product" | sed 's/^/    /'
  echo
  echo "  Either:"
  echo "    • run /changelog and add an entry under ## [Unreleased], or"
  echo "    • label the PR 'no-changelog' when the change is a pure refactor,"
  echo "      a formatting pass, test-only work, or regenerated output."
  exit 1
}

if ! printf '%s\n' "$changed" | grep -qxF "$changelog"; then
  fail "product code changed, but $changelog was not touched"
fi

# Touching the file is not the same as recording anything: a reflow or a typo
# fix would otherwise satisfy the check. Require at least one added bullet.
entries=$(git diff -U0 "$base_ref...HEAD" -- "$changelog" | grep -cE '^\+- ' || true)
if [ "$entries" -eq 0 ]; then
  fail "$changelog changed, but gained no new entry"
fi

echo "✓ $entries changelog entr$([ "$entries" -eq 1 ] && echo y || echo ies) for this branch's product changes"
