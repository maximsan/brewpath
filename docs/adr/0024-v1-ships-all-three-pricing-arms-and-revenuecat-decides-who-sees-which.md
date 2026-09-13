# ADR-0024: v1 ships all three pricing arms, and RevenueCat decides who sees which

- **Status:** accepted
- **Date:** 2026-09-12

## Context

[ADR-0003](0003-one-time-purchase-no-trial.md) ruled that v1 sells one
one-time purchase and that the pricing experiment runs *after* launch. The app
has since built the experiment: copy for all three arms, monthly and yearly
terms beside the lifetime one, and a plan picker.

What was never built is the part that makes it an experiment. The arm comes
from a compile-time flag, `--dart-define=MONETIZATION_MODEL`, so every learner
in a build sees the same paywall. That is a development switch, not an
assignment. The two subscription ids are placeholders that no store prices, so
those paywalls can be looked at but not bought from.

Nothing would measure the result either. The app has no backend and Firebase is
switched off, so there is nowhere to record which arm a learner saw or what
they paid — and App Store Connect's own figures do not split by arm at all.
Building that is a server; renting it is not. Argument:
[StoreKit: make the purchase real](https://github.com/maximsan/brewpath/issues/421).

## Decision

**v1 ships able to sell all three arms, and registers all three products.**
Which arms are actually live, and how learners are split between them, is a
setting from then on rather than a release. Launching on the one-time arm alone
stays open; launching unable to sell the others does not.

**RevenueCat does the assigning, holds the entitlement and reports the
revenue.** The app keeps its own paywall screens — RevenueCat's paywall builder
is not used — and reaches it through the existing `PaymentsService` seam
([#176](https://github.com/maximsan/brewpath/issues/176)), so no feature code
learns that it exists.

**No arm carries a trial**, unchanged from ADR-0003: the free lessons are the
trial.

## Consequences

- All three products are registered against v1's submission, even if only one
  sells at first: the non-consumable, plus a subscription group holding a
  monthly and a yearly. Apple takes the first in-app purchase **of each type**
  only in a submission carrying an app version, and a subscription is a
  different type from a non-consumable, so registering that group later would
  cost another release rather than a dashboard change
  ([Submit an In-App Purchase](https://developer.apple.com/help/app-store-connect/manage-submissions-to-app-review/submit-an-in-app-purchase/)).
- **Entitlement stops being permanent.** `courseEntitlement` answers once and
  stays answered, which is wrong for a subscription that lapses, is refunded or
  fails to renew. It has to be able to turn back off while the app is open, and
  every gate in the app reads it. This is the one piece of real design work the
  decision creates, and it has to be in the shipped build: a build that cannot
  expire an entitlement cannot have a subscription switched on from a
  dashboard.
- RevenueCat is the first live service the app depends on, in an app that is
  otherwise offline-first. An entitlement check still has to answer with no
  network, from the last answer it cached.
- Purchase data leaves the device to a third party. The privacy policy and the
  App Store privacy labels have to say so before submission.
- Apple reviews a subscription paywall harder than a one-time one. On the two
  arms that sell a subscription, the price, the period and what renews belong
  on screen at the buy button, and the app needs a way to reach Apple's own
  manage-subscriptions screen.
- ADR-0003's replacement test stands as written: an arm beats the one-time
  baseline on 90-day revenue per learner, without more refunds or worse
  reviews. It is now a question the data can answer.
- `--dart-define=MONETIZATION_MODEL` stays, for standing on an arm locally
  without a network or a store.
