# ADR-0005: Mini-games are many games per kind, gated by topic

- **Status:** accepted
- **Date:** 2026-08-20

## Context

The practice pool is 37 authored rounds across 7 games, and Keep Sharp rotates
a finished learner over it forever. Growing each game's single bank was the
plan ([#162](https://github.com/maximsan/brewpath/issues/162)) until the
run-length ceiling surfaced: a run is the whole bank, so a bank past ~7 rounds
pushes a ~2-minute run toward 4–5 minutes, against the five-minute-app bet.
Splitting into more, smaller games grows content without longer runs — and the
existing machinery (streak day-sets keyed by game id, the daily allowance,
one topic→module field per entry for tier gating) supports more entries with
zero changes. The word *"format"* had already caused one retraction (#56) by
meaning both the mechanic and the entry.

## Decision

A mini-game **kind** is the mechanic (the code's `kind` field: match, quiz,
bagpick, …). A **game** is one catalog entry — a kind plus exactly one course
topic plus a bank of **5–7 rounds** (5 the default) — with a persistent id.
Games are what the streak, the allowance, and tier gating count; two games of
the same kind are two *different* games for the streak's two-different rule.

- **Tier derives from topic**: a game is free iff its topic's module is
  unlocked. New games take new (paid-module) topics; the free catalog widens
  only if what's unlocked widens
  ([#175](https://github.com/maximsan/brewpath/issues/175)).
- **A locked game's gate sheet leads with "Taught in Module N"** — a targeted
  course pitch at peak intent, not a generic lock.
- **Counts are uneven by topic fit** — initial wave ~2 games per kind where a
  topic suits the mechanic (`bagpick` may stay at 1), ≈12–14 games.
- **Ids**: the existing seven are persisted in stored day-sets and are frozen;
  new ids are topic-slugged (`g-<kind>-<topic>`).
- **Catalog**: grouped by kind, fixed order, per-game lock marks
  ([#125](https://github.com/maximsan/brewpath/issues/125)).

Rejected: growing single banks past 7 rounds (run length); authoring free
sibling games on preview material (re-treads the 12-term free vocabulary and
moves the free tier by authoring rather than by ruling); an all-free catalog
(mini-game rounds are compressed course content — ~70 free rounds would ship a
shadow of the course the one-time purchase sells, and would supersede #29's
unlocked-material rule and #66's conversion-pressure ruling by side effect).

## Consequences

[ADR-0001](0001-free-tier-carries-two-mini-game-formats.md)'s invariant is
restated in this vocabulary and survives: **the free tier always carries at
least two free games with distinct ids, so a free learner can reach a
qualifying streak day using only free content.** #162's "double the free
pair" is dropped — free banks may top up to 7 rounds, no more, and free
practice relief has exactly one lever, #175. Authoring cost is honest: the
unit is a game (identity + bank), not a round. Keep Sharp, the snapshot
schema and the seeded shuffle are unchanged by construction. Per-learner
growing banks and per-run sampling remain out of scope — the next variety
lever after this catalog is exhausted. Revisit if run length or the topic
supply breaks the ~2-per-kind assumption.
