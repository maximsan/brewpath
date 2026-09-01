# ADR-0014: The module reward is the back of the flip, not a screen after it

- **Status:** accepted
- **Date:** 2026-08-31

## Context

`prototype/` describes the module ending two ways. The running prototype plays
one route that turns over to reveal the collectible. Four companion documents —
`module.html` (M4), `lesson.html` (L3), `screens-overview.html` (screen 12) and
`v1 Readiness Audit.html` — list the card as its own beat, and a finished
`ModuleRewardCardScreen` exists to serve it.

Argument and evidence: [#230](https://github.com/maximsan/brewpath/issues/230).

## Decision

**The module ending is one route**: a `RoastyMoment` held 2200 ms, the
celebration face, then the whole screen turned over to the collectible. The
flip is reversible — its back returns to the celebration.

**`ModuleRewardCardScreen` does not ship.** Nothing sets its route:
`continueFromModuleComplete` (`prototype/app.jsx:984`) is its only caller and is
never invoked, so it is reachable solely through the `?screen=` review harness.

The card cannot live in both places — the flip's back and a dedicated screen
carry the same eyebrow, the same `RewardCard` and the same terminal button.

## Consequences

The module ending is **two beats over one route**. Both *"two phases over two
routes"* (#230 as filed) and *"four beats over two routes"*
([Audit C](https://github.com/maximsan/brewpath/issues/373)) are wrong, having
each counted a route that never runs.

A finished screen sits unreferenced in `prototype/`, and four companion
documents still describe it as a step. An audit reading any of them will re-file
it as a missing screen — this record is what says otherwise.

**Revisit if** the prototype wires `module-card` into the flow, which would make
the missing call an omission rather than a superseded take.
