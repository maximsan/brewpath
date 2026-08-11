#!/usr/bin/env bash
#
# reset_ios_spm.sh — break-glass fix for the iOS "Target Integrity" SPM error.
#
# WHEN TO RUN THIS
#   Run it ONLY when `flutter build ios` fails with a "Target Integrity" error
#   of the form:
#
#       The package product '<some-package>' requires minimum platform
#       version <X> for the iOS platform, but this target supports <Y>
#
#   The named package is incidental — it can be any SPM dependency (firebase-*
#   or otherwise) whose platform floor is higher than the target SPM thinks it
#   has. The trigger is the integrity mismatch itself, not a specific package.
#
#   Our live config (ios/Runner.xcodeproj + the Flutter-generated SPM package)
#   already targets the correct iOS version. That error means Xcode is replaying
#   a STALE resolved Swift Package graph cached from an older build (back when
#   the deployment target was lower). Nothing in the repo is wrong — the caches
#   just need to be wiped so SPM re-resolves against the current target.
#
#   This is NOT a routine build step. Wiping the SPM cache forces a full
#   re-download + recompile of the entire dependency tree (minutes), so only
#   pay that cost when you actually hit the error.
#
# USAGE
#   ./tool/reset_ios_spm.sh            # clean only; you run `flutter build ios` after
#   ./tool/reset_ios_spm.sh --build    # clean, then build iOS (no codesign) in one go
#
set -euo pipefail

# Resolve the Flutter project root (the repo root) from this script's location,
# so it works no matter which directory you invoke it from.
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "==> Project: $PROJECT_ROOT"

# 1. flutter clean
#    Deletes build/ and ios/Flutter/ephemeral/ (the generated plugin SPM
#    package lives here). This guarantees the Package.swift that declares the
#    iOS platform gets regenerated from the current deployment target.
echo "==> [1/4] flutter clean"
flutter clean

# 2. Remove Xcode DerivedData for this app
#    DerivedData holds the *resolved* package graph — the actual source of the
#    stale "supports an older version" claim. Runner-* covers the per-build
#    hash folders.
echo "==> [2/4] Removing Xcode DerivedData (Runner-*)"
rm -rf ~/Library/Developer/Xcode/DerivedData/Runner-*

# 3. Reset the workspace-local SPM build/resolution state
#    .build holds the resolved + checked-out packages for the workspace. The
#    in-repo build/ios/SourcePackages is a second copy CLI builds may reuse.
echo "==> [3/4] Resetting workspace SPM state"
rm -rf ios/Runner.xcworkspace/xcshareddata/swiftpm/.build
rm -rf build/ios/SourcePackages

# 4. Reset the global Swift Package Manager cache
#    Shared across all Xcode projects on the machine. Wiping it forces a clean
#    re-resolution so no other project's stale graph can leak in.
echo "==> [4/4] Resetting global SwiftPM cache"
rm -rf ~/Library/Caches/org.swift.swiftpm

# Re-fetch Dart/Flutter deps. This also regenerates the ephemeral plugin SPM
# package (at the current deployment target) that step 1 deleted.
echo "==> Re-fetching dependencies (flutter pub get)"
flutter pub get

# Optional: chain straight into the iOS build. Off by default so you can
# inspect state first; pass --build to do it sequentially in one command.
if [[ "${1:-}" == "--build" ]]; then
  echo "==> Building iOS (release, no codesign) — fresh SPM resolution at current target"
  flutter build ios --release --no-codesign
else
  echo "==> Clean complete. Now run:  flutter build ios --release --no-codesign"
fi
