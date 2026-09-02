# ADR-0003: v1 sells one one-time purchase, with no trial

- **Status:** accepted
- **Date:** 2026-08-19

## Context

The whole course takes 129 minutes to complete. A 7-day free trial would give
most of that away for nothing. A subscription has the opposite problem: a
user who actually engages finishes the course within a month and cancels. An
earlier ruling had rejected a lifetime purchase — but it rejected it as a
*third* product beside two subscriptions. On its own, a one-time purchase
needs less machinery than the subscriptions it replaces: no renewal, no
expiry, no plan changes. Argument:
[Offers, plans and the paywall pitch](https://github.com/maximsan/brewpath/issues/55).

## Decision

v1 sells a **single one-time purchase** that unlocks BrewPath Plus. No trial.
No subscriptions. The paywall's pitch, in order: the rest of the course,
deeper practice, the Studios. It carries the required Restore, Terms and
Privacy links.

**The pricing model is not finally decided.** After launch, an experiment
will show different users different paywalls — one-time (this baseline),
subscription, and hybrid — and the revenue data will pick the winner. The
owner expects a subscription or hybrid to win. This ADR records what launches
and what the baseline is, not the final answer.

**No arm of that experiment carries a trial** (owner ruling): the free
lessons are the trial. Free access is limited by content, not by waiting.

## Consequences

- These prototype pieces are not built: `PlanSheet`, the
  renew/change-plan/cancel parts of `SubscriptionScreen`, `TRIAL_DAYS`,
  `trialDaysLeft`, `TrialBadge`.
- The build must keep three things separated: knowing what the user owns
  (entitlement), buying (acquisition), and the paywall screens
  ([the entitlement seam](https://github.com/maximsan/brewpath/issues/176)).
  The experiment shows different users different paywalls at the same time,
  so each user must be assigned one paywall and keep it — and whatever they
  buy, on any arm, stays owned forever through the same entitlement.
- The baseline is replaced only if another arm beats it on 90-day revenue per
  user without more refunds or worse reviews.
