# ADR-0003: v1 sells one one-time purchase, with no trial

- **Status:** accepted
- **Date:** 2026-08-19

## Context

[Offers, plans and the paywall pitch](https://github.com/maximsan/brewpath/issues/55)
ruled monetization on one measured fact: **the whole course is 129 minutes**. A
7-day trial gives the product away and is a gate made of waiting, which
contradicts §7's founding principle (*"free access is limited by content, not by
waiting"*) — the two preview lessons already are the trial. A subscription is
dishonest from the other side: an engaged subscriber finishes in 16–32 days and
churns (~$5–15 lifetime), and §1 rules out the content pipeline that would make
renewal honest, so subscription upside comes mostly from low-usage payers —
revenue that arrives with refunds and review damage.

This supersedes the earlier "lifetime tier dropped" position
(`docs/decisions.md`, `docs/design/PRODUCT.md` §11). That rejection was of
lifetime as a **third SKU beside two subscriptions**; standing alone, a
non-consumable has no renewal, expiry, plan-change or billing-retry state — it
is *less* machinery than the subscriptions it replaces, and Restore is required
for both types anyway.

## Decision

v1 sells a **single non-consumable purchase** unlocking BrewPath Plus. No
trial, no subscription SKUs. The paywall leads with the course (the remaining
lessons), then practice depth, then the Studios, and carries Restore / Terms /
Privacy.

## Consequences

- `PlanSheet`, the renewal/change-plan/cancel half of `SubscriptionScreen`,
  `TRIAL_DAYS`, `trialDaysLeft` and `TrialBadge` do not port; the map's
  no-clock warning stops applying to monetization.
- **This is the baseline of a planned post-launch experiment, not a terminal
  ruling** (product-owner direction, Aug 2026 — recorded on
  [#164](https://github.com/maximsan/brewpath/issues/164)): one-time only vs
  subscription (monthly + yearly) vs hybrid, likely via RevenueCat. The build
  therefore keeps **entitlement, acquisition and paywall UI separated**
  ([#176](https://github.com/maximsan/brewpath/issues/176)) so switching models
  is configuration, not a rewrite of access logic.
- **Revisit if** post-launch data beats the baseline on 90-day revenue without
  elevated refunds, or Keep Sharp engagement shows multi-month practice — the
  renewable value that would make a recurring charge honest.
