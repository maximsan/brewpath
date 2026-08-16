# ADR-0001: The free tier carries exactly two mini-game formats

- **Status:** accepted
- **Date:** 2026-08-16

## Context

Three decisions, each sound alone, together create an invariant that no single
one of them states.

**The free tier is a preview, not a generous tier.** It holds 2 lessons of 32
([#29](https://github.com/maximsan/brewpath/issues/29)), which a learner
exhausts on their second day.

**The streak needs two _different_ mini-games in a local calendar day.** One run
is not enough and the same game twice counts once
([#22](https://github.com/maximsan/brewpath/issues/22), upheld at
[#59](https://github.com/maximsan/brewpath/issues/59)). The rule stands on
content variety — two different games are eleven distinct rounds where a repeat
is five rounds seen twice — rather than on the anti-farming argument it was
first given, which does not survive measurement.

**Which mini-games are free follows from which lessons are free.** Each game
advertises exactly one topic, so gating is by format, and the free pair —
`g-match` (Arabica vs Robusta) and `g-quiz` (coffee basics) — is *forced* by the
topic mapping onto the two free lessons rather than chosen
([#57](https://github.com/maximsan/brewpath/issues/57)). No other pair
corresponds.

The consequence nobody wrote down: **the free tier contains exactly the two
formats the streak rule requires, and not one more.**

This is not the free learner's *only* streak path, and an earlier framing that
said so was superseded:
[#33](https://github.com/maximsan/brewpath/issues/33) settled that **one**
qualifying completion protects the day, and that a completed lesson replay, a
Vocab round and a Flashcard session each qualify alone. Mini-games are the
single activity needing two, so they are also the *most expensive* path — two
runs spend a free learner's whole daily allowance where a replay spends one.

What the pair protects is the only non-lesson path that stays varied: two
different games are eleven distinct rounds, against the same two lessons
replayed daily. Remove one format and a free learner's practice collapses back
onto content they have already finished.

## Decision

The free tier carries **exactly two mini-game formats**, and the streak requires
two different games. Any change to the free lesson pair, to the tier's format
list, or to the streak's distinctness requirement **must preserve the property
that a free learner can reach a qualifying streak day using only free content.**

A change that breaks it is allowed, but it must be taken deliberately and
recorded here as a superseding record — not arrived at as a side effect of
re-picking which lessons are free.

## Consequences

**Easy.** A free learner has a daily reason to open the app that costs no
content and no new authoring, and a learner past lesson 32 has a practice path
that is not re-walking what they already know.

**Hard.** The invariant is invisible from every surface that could break it.
Cutting a free format, swapping one, or re-picking the free lesson pair without
re-deriving the mapping each removes the free streak path silently — the tier
documents do not mention the streak, and the streak documents do not mention the
tier. This record is the join.

**Also load-bearing from the other side.** The daily allowance caps a free user
at two activities per day
([#65](https://github.com/maximsan/brewpath/issues/65)), and two mini-games
spend both. Lowering that cap below two removes the mini-game path outright,
without touching mini-games at all — the free learner would keep a streak only
through the single-activity routes.

**Revisit if** the streak drops the distinctness requirement — it was reversed
once and restored ([#59](https://github.com/maximsan/brewpath/issues/59)) — if
the free tier's lesson count changes, if the daily allowance cap moves, or if
free-tier practice variety ([#66](https://github.com/maximsan/brewpath/issues/66))
is answered by widening the free pool rather than by authoring.
