# ADR-0010: v1 onboarding is five screens, and the question flow is v2

- **Status:** accepted
- **Date:** 2026-08-28

## Context

The Readiness Audit defers the personalisation questions to v2 — nothing
reads the answers, so they cost taps and return nothing. The app built the
flow anyway: goal and brewer ship, gating the whole app behind questions no
screen reads. [The onboarding conflict](https://github.com/maximsan/brewpath/issues/370)
asked which way it falls; it falls the audit's way, with the paywall closing
the flow.

## Decision

**v1 onboarding is five screens, in order:** Loading (the boot screen, an
onboarding step only by accident of ordering) → Welcome (no Roasty, by the
design's own note) → Meet Roasty (its own screen, not collapsed into
Welcome) → Name (optional, the only optional step) → Paywall.

**Goal, brewer, level and reminders leave the v1 flow** — v2, at the
four-question depth v2 will ship.

**The name step stays, and the name becomes editable.** Nothing else in v1
can supply a name — no account, no sign-in — and Profile's `Hello, {name}.`
already carries a fallback for anyone who skips. Settings gains a row that
writes `learnerName`, so a typo is correctable.

**The router's gate stops depending on the questions.** `onboardingCompleted`
still gates the app, but nothing downstream may read a goal or a brewer —
after this, no learner supplies one.

## Consequences

**The name screen owes a design.** The prototype has no name step, so today
it draws a stock Material text field no other screen uses. A recorded
divergence, not an oversight, until the owner authors the screen.

The Tour's trigger rules were defined against the longer flow and must be
re-read — [the Tour map](https://github.com/maximsan/brewpath/issues/336).

Builds: [the intro screens](https://github.com/maximsan/brewpath/issues/383),
[the onboarding paywall](https://github.com/maximsan/brewpath/issues/242),
plus the cut itself and the Settings row.

**Revisit** when something actually reads a goal or a brewer — deferring them
is a statement about v1's readers, not about the questions.
