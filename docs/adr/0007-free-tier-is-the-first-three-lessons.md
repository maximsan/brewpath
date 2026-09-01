# ADR-0007: The free tier is the first three lessons, lesson-bound

- **Status:** accepted
- **Date:** 2026-08-22
- **Reaffirmed** 2026-08-28: the Readiness Audit's line widening the free
  taster to all of Module 1 is the stale artifact; this record had already
  weighed and refused it ([#370](https://github.com/maximsan/brewpath/issues/370)).

## Context

The free tier was the two preview lessons, and
[free tier scope](https://github.com/maximsan/brewpath/issues/175) asked
whether all of Module 1 should replace them. Meanwhile the new catalog
shipped a free game quizzing `m1l3` — a **paid** lesson at the time. A free
user could sit an exam for a class they could not attend. Making `m1l3` free
fixes it.

## Decision

Free is **the first three lessons** — `m1l1` *What coffee actually is* ·
`m1l2` *Arabica vs Robusta* · `m1l3` *What origin means* — permanently, with
unlimited replay.

The free set is a **named lesson list**, and everything downstream derives
from it: a game is free iff its topic's **teaching lesson** is free (never
"its module is m1"), the free vocab pool is the free lessons' mentioned-in
terms, and tier-dependent counts re-derive. Growing the free tier later is a
change to one list.

Rejected: the preview pair (leaves the shipped catalog invalid) and all of
Module 1 (~22% of a 129-minute product; the owner weighs the mid-module wall's
cost below that — the wall stays at `m1l4`).

## Consequences

Free practice becomes three games with a real choice under the
two-different-games rule. [ADR-0001](0001-free-tier-carries-two-mini-game-formats.md)'s
"exactly two" phrasing is superseded by this count; its invariant holds. The
paywall needs no edit — every quantity derives. The prototype's
`FREE_GAME_IDS` filter is correct by coincidence (module-bound) and owes the
lesson-bound fix ([#225](https://github.com/maximsan/brewpath/issues/225)).

**Revisit** only with post-launch data, as a change to the free-lesson list.
