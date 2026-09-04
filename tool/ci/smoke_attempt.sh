#!/bin/bash
# Runs one attempt of the CI smoke test: $1 is the attempt number, the rest is
# the `flutter test` command. Its verbose output goes to smoke-attempt-$1.log.
#
# Only the launch is bounded, not the whole command. On the runner the Xcode
# build alone has taken 4 to 9 minutes, and healthy runs have taken up to
# 19 minutes end to end, so a bound on the whole command kills passing runs —
# it did, on main, on 2026-09-04 (22 seconds after the app had connected).
# A hang looks different: "Xcode build done" is printed, the app is launched,
# and no test ever reports. A healthy run reports its first test about
# 50 seconds after the build. So the clock starts at "Xcode build done", and
# an attempt that has not reported a test LAUNCH_BOUND_SECONDS later is
# stopped with exit code 142 — the only code the caller retries on. Anything
# else (build failure, a failing test) is the command's own exit code.
set -uo pipefail

ATTEMPT=$1
shift
LOG="smoke-attempt-$ATTEMPT.log"
LAUNCH_BOUND_SECONDS=${LAUNCH_BOUND_SECONDS:-300}
LAUNCH_HUNG=142
# The tool's own wording: a run that got as far as running tests prints
# per-test results and "test package returned with exit code".
REPORTED='test package returned with exit code|^(✅|❌)|::group::(✅|❌)'

# Its own process group, so stopping it also stops what it spawned (the
# simulator log stream, the device launch). macOS ships no setsid.
perl -e 'setpgrp(0, 0); exec @ARGV' "$@" >"$LOG" 2>&1 &
PID=$!

built_at=""
while kill -0 "$PID" 2>/dev/null; do
  if [ -z "$built_at" ] && grep -q 'Xcode build done' "$LOG"; then
    built_at=$(date +%s)
  fi
  if [ -n "$built_at" ] &&
    [ $(($(date +%s) - built_at)) -ge "$LAUNCH_BOUND_SECONDS" ] &&
    ! grep -q -E "$REPORTED" "$LOG"; then
    echo "attempt $ATTEMPT: the app was built $LAUNCH_BOUND_SECONDS s ago and no test has reported — the launch hung; stopping it"
    kill -TERM -- "-$PID" 2>/dev/null
    wait "$PID" 2>/dev/null
    exit "$LAUNCH_HUNG"
  fi
  sleep 5
done
wait "$PID"
