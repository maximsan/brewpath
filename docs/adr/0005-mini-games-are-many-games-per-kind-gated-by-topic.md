# ADR-0005: Mini-games are many games per kind, gated by topic

- **Status:** accepted
- **Date:** 2026-08-20

## Context

Keep Sharp rotates a user who finished the course through the practice pool
forever, so the pool has to grow. The original plan was to add rounds to each
existing game. That hit a limit: one run always plays a game's whole bank, so
a bank past about 7 rounds stretches a two-minute run toward five — and the
product is built on sessions staying under five minutes. Adding *more, smaller
games* grows the content without making any single run longer, and the
existing streak, limit and gating code already handles more games with no
changes. Argument:
[practice pool depth](https://github.com/maximsan/brewpath/issues/162).

## Decision

Two words get fixed meanings. A **kind** is the game mechanic — the code's
`kind` field: match, quiz, bagpick, and so on. A **game** is one entry in the
catalog: a kind, plus exactly one course topic, plus a bank of **5–7 rounds**,
under a permanent id. The streak, the daily limit and the paywall gating all
count *games*. Two games of the same kind count as two different games for
the streak's two-different-games rule.

- **Whether a game is free follows from its topic**: a game is free exactly
  when the lesson teaching its topic is free. The set of free games grows
  only when the set of free lessons grows
  ([free tier scope](https://github.com/maximsan/brewpath/issues/175)).
- **The lock screen of a paid game says "Taught in Module N"** — it sells the
  specific course module, not a generic upgrade.
- **Ids**: the seven existing game ids are stored in users' streak history
  and must never change. New ids follow the pattern `g-<kind>-<topic>`.
- **The catalog** is grouped by kind, in a fixed order, with a lock mark on
  each paid game ([the catalog](https://github.com/maximsan/brewpath/issues/125)).

Three alternatives were rejected — bigger banks, free copies of games built
on preview content, and making the whole catalog free. The reasons are on
the ticket.

## Consequences

The rule from [ADR-0001](0001-free-tier-carries-two-mini-game-formats.md)
survives, reworded: **the free tier always carries at least two free games
with different ids**, so a free user can still earn a streak day. The unit of
authoring work is a game — an identity plus a bank — not a single round. Keep
Sharp, the saved-data format and the shuffle code need no changes. Banks that
grow per user, and runs that sample a subset of a bank, stay out of scope;
they are the next lever once this catalog is used up.

**Revisit if** runs get too long anyway, or the course runs out of topics
that fit a mechanic.
