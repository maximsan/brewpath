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

**What v1 ships:** a **single non-consumable purchase** unlocking BrewPath
Plus. No trial, no subscription SKUs. The paywall leads with the course (the
remaining lessons), then practice depth, then the Studios, and carries
Restore / Terms / Privacy.

**What stays open:** the monetization **model itself is not finally decided.**
A post-launch experiment shows **different paywalls to different users** —
one-time (this baseline) vs subscription (monthly + yearly) vs hybrid — and
the data picks the model. The owner's stated expectation (Aug 2026) is that
**hybrid or subscription wins** on revenue; the skepticism in Context is the
counter-hypothesis the experiment exists to test, not a verdict. This ADR
records the launch configuration and the baseline arm, not a terminal ruling
on how BrewPath charges.

## Consequences

- `PlanSheet`, the renewal/change-plan/cancel half of `SubscriptionScreen`,
  `TRIAL_DAYS`, `trialDaysLeft` and `TrialBadge` do not port; the map's
  no-clock warning stops applying to monetization.
- The experiment (likely via RevenueCat) requires the build to keep
  **entitlement, acquisition and paywall UI separated**
  ([#176](https://github.com/maximsan/brewpath/issues/176)) — and because arms
  run **concurrently per user**, not sequentially, the seam must support
  stable per-user paywall assignment, with any arm's purchase honored by the
  same entitlement forever, even after the experiment ends.
- **The experiment resolves the model.** The bar for moving off the baseline:
  beating it on 90-day revenue per user without elevated refunds or review
  damage; Keep Sharp showing multi-month practice would independently supply
  the renewable value that makes a recurring charge honest.
- **No trial in any arm** (owner ruling, Aug 2026): the free content is the
  trial. §7's principle — free access limited by content, not by waiting —
  applies across the whole experiment, so subscription and hybrid arms carry
  no intro free week either.
