#!/bin/bash
# Boots the simulator whose UDID is $1 from a clean slate and returns once it
# can take an app launch. Used by the CI smoke job for the first boot and for
# the reboot before a retry — both must go through the same wait, because an
# app launched into a simulator that is still coming up hangs `flutter test`.
#
# The runner image's preinstalled iPhone carries data from an older runtime
# build, and its first boot spends minutes in "Data Migration" (measured on
# three runs: 2 min 11 s, 7 min 08 s, 8 min 51 s). `simctl list` reports the
# device as Booted long before that finishes; only `bootstatus -b` waits for
# SpringBoard. It is bounded because it can hang on some states — and then
# this script fails with the reason, rather than launching too early.
set -euo pipefail

UDID=$1
BOOT_BOUND_SECONDS=${BOOT_BOUND_SECONDS:-720}

xcrun simctl shutdown "$UDID" >/dev/null 2>&1 || true
xcrun simctl erase "$UDID"
# `|| true`: already-booted is reported as an error, and is fine.
xcrun simctl boot "$UDID" || true

for _ in $(seq 1 30); do
  if xcrun simctl list devices | grep -q "$UDID.*Booted"; then
    echo "Booted; waiting for SpringBoard (up to $((BOOT_BOUND_SECONDS / 60)) minutes)"
    if perl -e 'alarm shift; exec @ARGV' "$BOOT_BOUND_SECONDS" xcrun simctl bootstatus "$UDID" -b; then
      exit 0
    fi
    echo "simulator $UDID booted but never finished coming up (bootstatus did not reach a terminal state in $((BOOT_BOUND_SECONDS / 60)) minutes)"
    exit 1
  fi
  sleep 2
done
echo "simulator $UDID never reached Booted"
exit 1
