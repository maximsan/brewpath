# ADR-0007: The free tier is the first three lessons, lesson-bound

- **Status:** accepted
- **Date:** 2026-08-22

## Context

`docs/decisions.md` §7 fixed the free tier at the two preview lessons, and
[Free tier scope (#175)](https://github.com/maximsan/brewpath/issues/175)
asked whether all of Module 1 (7 lessons, 26 of the course's 129 minutes)
should replace them. Meanwhile the landed catalog
([ADR-0005](0005-mini-games-are-many-games-per-kind-gated-by-topic.md))
shipped a new free game, *Name the origin*. A game quizzes one lesson's
material, and this one quizzes `m1l3` — which was still a **paid** lesson at
the time. So a free user could play a quiz about origins while the lesson
teaching origins sat behind the paywall: an exam for a class they could not
attend. The Decision below fixes this by making `m1l3` free.

## Decision

Free is **the first three lessons** — `m1l1` *What coffee actually is* ·
`m1l2` *Arabica vs Robusta* · `m1l3` *What origin means* — permanently, with
unlimited replay. The free set is a **named lesson list**, and everything
downstream derives from it: a game is free iff its advertised topic's
**teaching lesson** is free (never "its module is m1"), the practice vocab
pool is the mentioned-in terms of the free lessons, and tier-dependent counts
re-derive. Growing the free tier later is a change to one list.

Rejected: the **preview pair** (leaves the shipped catalog invalid) and
**all of Module 1** (~22% of a 129-minute product spent on a
conversion-boundary argument the owner weighs below its cost — the
module-complete free arc and the "You finished Beans" pitch moment are
consciously forgone; the wall stays mid-module, now at `m1l4` *Why altitude
matters*).

## Consequences

Free practice becomes **3 games / 18 rounds** with a real choice under the
two-different-games streak rule, and ~3 days of fresh content under the
2-activity cap — the demo-tier doctrine (§7, #29) unchanged in kind, no
longer thinner than the catalog. [ADR-0001](0001-free-tier-carries-two-mini-game-formats.md)'s
invariant is restated: the free tier carries **at least two** free games with
distinct ids (now three); its "exactly two" phrasing is superseded by this
count. The paywall needs no edit — #89 derives every quantity ("29 more
lessons" computes itself). The prototype's `FREE_GAME_IDS` filter is
correct-by-coincidence (module-bound) and owes the lesson-bound fix
([#225](https://github.com/maximsan/brewpath/issues/225)). Revisit only with
post-launch data, as a change to the free-lesson list.
