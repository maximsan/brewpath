# ADR-0001: The free tier carries exactly two mini-game formats

- **Status:** accepted
- **Date:** 2026-08-16
- **Restated** by [ADR-0005](0005-mini-games-are-many-games-per-kind-gated-by-topic.md)
  ("format" became **game**) and [ADR-0007](0007-free-tier-is-the-first-three-lessons.md)
  (two free games became three). The invariant below is the part that holds.

## Context

Three rulings, each sound alone, combine into an invariant none of them
states:

- The free tier is a small preview, not a generous tier.
- A streak day earned from mini-games alone needs **two different games** —
  the same game twice counts once.
- Which games are free follows from which lessons are free, so the free game
  list is derived, never picked.

Together they mean the free tier only just contains enough games for a
mini-game streak day. Nothing else says so. Argument:
[the mini-games decision](https://github.com/maximsan/brewpath/issues/22),
[free practice content](https://github.com/maximsan/brewpath/issues/57),
[the distinctness reversal](https://github.com/maximsan/brewpath/issues/59).

## Decision

Any change to the free lesson list, the free game list, or the streak's
two-different-games rule must keep this true: **a free learner can reach a
qualifying streak day using only free content.**

Breaking it is allowed — but deliberately, in a superseding ADR. Never as a
side effect of re-picking which lessons are free.

## Consequences

The invariant is invisible from every surface that can break it: the tier
documents do not mention the streak, and the streak documents do not mention
the tier. This record is the join.

The daily allowance is load-bearing from the other side: it caps a free user
at two activities a day, and two mini-games spend both. Lowering that cap
below two removes this streak path without touching mini-games at all
([the allowance decision](https://github.com/maximsan/brewpath/issues/65)).

**Revisit if** the free lesson list, the game list, the distinctness rule, or
the allowance cap moves.
