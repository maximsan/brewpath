# ADR-0005: Mini-games are many games per kind, gated by topic

- **Status:** accepted
- **Date:** 2026-08-20

## Context

Keep Sharp rotates a finished learner over the practice pool forever, so the
pool must grow. Growing each game's single bank was the plan until the
run-length ceiling surfaced: a run is the whole bank, and a bank past ~7
rounds pushes a ~2-minute run toward five — against the five-minute-app bet.
More, smaller games grow content without longer runs, and the existing
machinery already supports more entries with zero changes. Argument:
[practice pool depth](https://github.com/maximsan/brewpath/issues/162).

## Decision

A mini-game **kind** is the mechanic (the code's `kind` field: match, quiz,
bagpick, …). A **game** is one catalog entry — a kind, exactly one course
topic, and a bank of **5–7 rounds** — with a persistent id. Games are what the
streak, the allowance and tier gating count; two games of the same kind are
two *different* games for the streak's two-different rule.

- **Tier derives from topic**: a game is free iff its topic's teaching lesson
  is free. The free catalog widens only if what is unlocked widens
  ([free tier scope](https://github.com/maximsan/brewpath/issues/175)).
- **A locked game's gate sheet leads with "Taught in Module N"** — a targeted
  course pitch, not a generic lock.
- **Ids**: the existing seven are persisted in stored day-sets and frozen; new
  ids are topic-slugged (`g-<kind>-<topic>`).
- **Catalog**: grouped by kind, fixed order, per-game lock marks
  ([the catalog](https://github.com/maximsan/brewpath/issues/125)).

Growing single banks, free sibling games on preview material, and an all-free
catalog were each rejected — the reasons live on the ticket.

## Consequences

[ADR-0001](0001-free-tier-carries-two-mini-game-formats.md)'s invariant
survives, restated: **the free tier always carries at least two free games
with distinct ids.** The authoring unit is a game (identity + bank), not a
round. Keep Sharp, the snapshot schema and the seeded shuffle are unchanged by
construction. Per-learner growing banks and per-run sampling stay out of
scope — the next variety lever once this catalog is exhausted.

**Revisit if** run length or the topic supply breaks the ~2-games-per-kind
assumption.
