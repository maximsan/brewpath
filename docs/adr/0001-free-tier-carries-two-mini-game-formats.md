# ADR-0001: The free tier carries exactly two mini-game formats

- **Status:** accepted
- **Date:** 2026-08-16
- **Restated** by [ADR-0005](0005-mini-games-are-many-games-per-kind-gated-by-topic.md)
  (the word "format" became **game**) and by
  [ADR-0007](0007-free-tier-is-the-first-three-lessons.md) (two free games
  became three). The rule below is the part that still holds.

## Context

Three separate rulings combine into one rule that none of them states on its
own:

- The free tier is a small preview of the course.
- To earn a streak day from mini-games alone, the user must finish **two
  different games** that day. Playing the same game twice counts as one.
- Which games are free is computed from which lessons are free. Nobody picks
  the free games by hand.

Put together: the free tier contains just enough free games for a free user
to earn a streak day — and nothing guarantees that on purpose. Argument:
[the mini-games decision](https://github.com/maximsan/brewpath/issues/22),
[free practice content](https://github.com/maximsan/brewpath/issues/57),
[the distinctness reversal](https://github.com/maximsan/brewpath/issues/59).

## Decision

Any change to the free lesson list, to the free game list, or to the
two-different-games rule must keep this true: **a free user can earn a streak
day using only free content.**

This rule may be broken — but only on purpose, recorded in a new ADR that
supersedes this one. It must never break as a side effect of changing which
lessons are free.

## Consequences

The rule is invisible from every place that can break it: none of the three
rulings above mentions it, and each of them can be changed without reading
the other two. This ADR is the only place the rule is written down.

The daily limit matters here too: a free user may do two activities per day,
and two mini-games use both. If that limit ever drops below two, the
mini-game route to a streak day disappears without anyone touching
mini-games ([the allowance decision](https://github.com/maximsan/brewpath/issues/65)).

**Revisit if** the free lesson list, the free game list, the
two-different-games rule, or the daily limit changes.
