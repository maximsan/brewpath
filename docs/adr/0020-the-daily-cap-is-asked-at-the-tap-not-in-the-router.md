# ADR-0020: The daily activity cap is asked at the tap, not in the router

- **Status:** accepted
- **Date:** 2026-09-05

## Context

`CLAUDE.md` rules that navigation policy lives in the router: *"Screens don't
duplicate gate→destination decisions; the `appRouter` redirect owns them."*
Every other gate obeys it — onboarding, the Studio, the course wall — and the
course wall's own comment argues for the redirect as the backstop no surface
can get wrong.

The free daily allowance ([#216](https://github.com/maximsan/brewpath/issues/216),
`docs/decisions.md` §8) cannot follow it. An activity is recorded **when it
finishes**, while the learner is still standing on the route that recorded it,
and the same write invalidates what the redirect reads. So the redirect is due
to re-run at the exact moment the route the learner is on has become one the
cap refuses — and it would bounce them off the results of the activity they
had just completed.

The course wall has no such problem because a lesson already finished never
locks (ADR-0016): the thing you just did cannot turn refusing behind you. A
volume cap cannot make that promise, because spending the allowance is
precisely what the completion does.

## Decision

The cap is asked **at the point the activity starts**, not in `redirectFor`.

`RouteDestination.startsActivity` marks the four destinations that begin one;
`BuildContext.goToActivity` / `pushActivity` ask the day's allowance before
following such a destination, and `mayStartAnotherActivity` asks it for a drill
that restarts in place without navigating.

## Consequences

- The question is only ever asked about a surface nobody is standing on, so no
  learner is evicted from a run in progress.
- There is **no router backstop**. Nothing outside the app can reach an
  activity route today — the universal-link claim is `/card/*` and nothing else
  — so the taps are the whole way in. If that ever stops being true, this
  decision has to be revisited rather than patched.
- A new way to start an activity must remember to ask. Two things make
  forgetting loud rather than silent: `BuildContext.goTo` asserts against an
  activity destination, and the destinations themselves carry the flag, so the
  question is attached to the thing being opened rather than kept in a list.
- The allowance re-derives on every read instead of joining
  `invalidateDaySurfaces`. A surface that misses an invalidation shows
  yesterday's number; an allowance that misses one hands out a free activity.
