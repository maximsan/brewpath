# ADR-0003: v1 sells one one-time purchase, with no trial

- **Status:** accepted
- **Date:** 2026-08-19

## Context

The whole course is 129 minutes. A 7-day trial gives it away, and a
subscription has an engaged subscriber finishing and churning within a month.
The earlier "lifetime tier dropped" ruling rejected lifetime as a third SKU
beside two subscriptions — standing alone, a one-time purchase is *less*
machinery than the subscriptions it replaces. Argument:
[Offers, plans and the paywall pitch](https://github.com/maximsan/brewpath/issues/55).

## Decision

v1 ships a **single non-consumable purchase** unlocking BrewPath Plus. No
trial, no subscription SKUs. The paywall leads with the course, then practice
depth, then the Studios, and carries Restore, Terms and Privacy.

**The model itself stays open.** A post-launch experiment shows different
paywalls to different users — one-time (this baseline), subscription, hybrid —
and the data picks the model. The owner expects hybrid or subscription to win;
this record is the launch configuration and the baseline arm, not a terminal
ruling.

**No trial in any arm** (owner ruling): the free content is the trial — free
access is limited by content, not by waiting.

## Consequences

- `PlanSheet`, the renewal half of `SubscriptionScreen`, `TRIAL_DAYS`,
  `trialDaysLeft` and `TrialBadge` do not port.
- The build keeps **entitlement, acquisition and paywall UI separated**
  ([the entitlement seam](https://github.com/maximsan/brewpath/issues/176)).
  Arms run concurrently per user, so the seam must support stable per-user
  paywall assignment, and any arm's purchase is honoured by the same
  entitlement forever.
- The bar for moving off the baseline: beating it on 90-day revenue per user
  without elevated refunds or review damage.
