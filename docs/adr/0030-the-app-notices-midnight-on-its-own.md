# ADR-0030: The app notices midnight on its own

- **Status:** accepted
- **Date:** 2026-09-18

## Context

Day-dependent surfaces — the streak, the freeze line, Keep Sharp, the header's
date, a Coffee Challenge's 48-hour window — were derived from `DateTime.now()`
at the moment a screen built. They were refreshed when the app resumed, so an
app left **foregrounded** across midnight kept showing yesterday until the
learner happened to tap something.

The earlier trade-off — no timer, because a read on resume answers it — was
made in a code comment rather than with the owner. Ruled on
[#202](https://github.com/maximsan/brewpath/issues/202), which has the
argument.

## Decision

**The app arms one timer for the next local midnight** while it is
foregrounded, re-arms it on every resume, and on firing refreshes the same
surfaces a resume does. A learner watching the app at midnight sees the day
turn over.

**There is one clock.** `appClockProvider` hands it out as a *function*, and is
the only read of `DateTime.now()` on a derivation path.

The function matters, because a day and a window want opposite things. A
calendar decision watches `currentDayProvider`, which calls the clock once and
holds that day until the rollover refreshes it — so every surface derived
against today agrees on which day that is. A window measured in elapsed hours
calls the function as it rebuilds: it wants the moment, and an instant the app
settled on hours earlier would leave a lapsed challenge looking live.

A resume inside one day invalidates nothing — the watcher compares the day
first. When the day is refreshed and lands on the same one, the value is equal
and Riverpod notifies nobody.

**A clock read that stamps a write stays a clock read.** The moment of an
acknowledgement, a challenge start, or a lesson completion *is* `now`, and
routing it through a cached provider would date it wrongly.

## Consequences

`invalidateDaySurfaces` still names every provider it refreshes instead of
leaning on the dependency graph: an overridden provider severs the very edge a
graph-based version would rely on, so no test could catch the wiring being
changed. The free day's allowance stays off that list deliberately — it
re-derives on every read (ADR-0020).

A guard test (`test/unit/app/day_reads_guard_test.dart`) fails the build if a
`build()` method, a `*_providers.dart` or a `*_watcher.dart` under
`lib/features/` reads the clock again, and if anything in `lib/app/` calls it
at all. Those are the places that decide what is true *now* away from any tap.
The defect is silent otherwise: nothing throws, a screen is just quietly wrong.

The timer costs one pending `Timer` per app run and fires at most once a day.
It does nothing while the app is backgrounded, which is the resume path's job.

**A challenge window is still only checked at those moments.** One that lapses
at 14:00 under an open app is noticed at the next midnight, resume or cold
start — not at 14:00. Per-challenge timers were not built; revisit if a
challenge ever needs to expire on screen.
