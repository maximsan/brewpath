# ADR-0007: The free tier is the first three lessons, lesson-bound

- **Status:** accepted
- **Date:** 2026-08-22
- **Reaffirmed** 2026-08-28: the Readiness Audit contains a line widening the
  free tier to all of Module 1. That line is outdated — this record had
  already considered exactly that and said no
  ([#370](https://github.com/maximsan/brewpath/issues/370)).

## Context

The free tier used to be the first two lessons, and
[free tier scope](https://github.com/maximsan/brewpath/issues/175) asked
whether all seven lessons of Module 1 should be free instead. While that was
open, the new mini-game catalog shipped a free game that quizzes lesson
`m1l3` — which was a *paid* lesson at the time. A free user could take a quiz
about coffee origins while the lesson teaching origins sat behind the
paywall. Making `m1l3` free fixes that.

## Decision

Free is **the first three lessons**, permanently, with unlimited replay:
`m1l1` *What coffee actually is*, `m1l2` *Arabica vs Robusta*, `m1l3` *What
origin means*.

The free tier is defined as **this list of lesson ids**, and everything else
is computed from the list: a game is free exactly when the lesson teaching
its topic is on the list (never "when its module is Module 1"); the free
vocabulary pool is the terms those three lessons mention; every count that
depends on tier is recomputed. Growing the free tier later means changing
this one list.

Two options were rejected: keeping the two-lesson tier (it leaves the shipped
quiz selling a lesson it already reveals), and freeing all of Module 1 (seven
free lessons is about 22% of a 129-minute course; the owner judged that too
much to give away, and accepted that the paywall therefore appears
mid-module, at `m1l4`).

## Consequences

Free practice becomes three games, which gives a free user an actual choice
under the two-different-games streak rule.
[ADR-0001](0001-free-tier-carries-two-mini-game-formats.md) said "exactly
two" free games; the count is now three, and ADR-0001's underlying rule
still holds. The paywall needs no edit, because every number on it is
computed. One bug is owed: the prototype's `FREE_GAME_IDS` filter checks the
module instead of the lesson — it gives the right answer with today's data,
but by luck, and [#225](https://github.com/maximsan/brewpath/issues/225)
carries the fix.

**Revisit** only with data from real users after launch, by changing the
free-lesson list.
