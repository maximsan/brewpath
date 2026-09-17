# BrewPath — Payments

## What v1 sells

Foundations, through **three arms of a pricing experiment** — one-time,
subscription, and hybrid ([ADR-0024](adr/0024-v1-ships-all-three-pricing-arms-and-revenuecat-decides-who-sees-which.md),
which supersedes ADR-0003). The build ships able to sell all three and
registers all three products; which arms are live, and who is split onto
which, is a RevenueCat setting rather than a release.

No arm carries a trial. The free lessons are the trial.

## How it is wired

Three concerns stay separated, and that separation is the whole design
([#176](https://github.com/maximsan/brewpath/issues/176)):

| Concern | Where it lives |
| --- | --- |
| What the learner owns | `courseEntitlement` — the one monetization concept feature code reads |
| Buying, and which arm they are on | `PaymentsService` and its implementations, in `lib/services/payments/` |
| What the paywall says | `lib/features/monetization/` |

The interface is the source; this doc does not restate it. Four
implementations of `PaymentsService`:

- `NoOpPaymentsService` — owns nothing, cancels every purchase. Active until
  the store lands.
- `GrantedPaymentsService` — owns everything. Development only, behind
  `--dart-define=GRANT_COURSE=true`.
- `RevenueCatPaymentsService` — the real one. **Not written yet**
  ([#421](https://github.com/maximsan/brewpath/issues/421)).
- `InAppPurchaseService` — an abandoned stub from when v1 was going to talk to
  StoreKit directly. Delete it when the RevenueCat one lands.

`paymentsProvider` picks one. Nothing outside `lib/services/payments/` names a
store SDK.

## Products

| What | Id | Type |
| --- | --- | --- |
| Buy Foundations once | `dev.maximsan.brewPath.plus` | Non-consumable |
| Monthly | `dev.maximsan.brewPath.plus.monthly` | Auto-renewable |
| Yearly | `dev.maximsan.brewPath.plus.yearly` | Auto-renewable |

The ids and the arm-to-SKU map live in
`lib/shared/models/monetization/plus_offering.dart` — `offeringFor(model)` is
the whole of "which SKUs does this arm sell".

**All three are registered in one submission**, even if only one sells at
first. Apple takes the first in-app purchase *of each type* only in a
submission carrying an app version, and an auto-renewable subscription is a
different type from a non-consumable — so leaving the subscription group until
later costs another release rather than a dashboard change
([Submit an In-App Purchase](https://developer.apple.com/help/app-store-connect/manage-submissions-to-app-review/submit-an-in-app-purchase/)).

## Going live checklist

**Owner's, in App Store Connect and RevenueCat:**

- [ ] Create the RevenueCat account and link it to App Store Connect (needs an
      App Store Connect API key)
- [ ] Register the non-consumable, and a subscription group holding the monthly
      and the yearly; price all three
- [ ] Mirror the three as RevenueCat entitlements and offerings — one offering
      per arm
- [ ] Create a sandbox tester account

**Code:**

Written in [#602](https://github.com/maximsan/brewpath/pull/602), and none of
it has met a real store — the sandbox box below is what verifies the rest.

- [x] Add `purchases_flutter`, and write `RevenueCatPaymentsService`
- [x] Return a real `currentOffering()` from RevenueCat's offerings. It must be
      **stable per learner** — an arm that changes between sessions is not an
      experiment. RevenueCat's current offering names the arm; `offeringArms`
      maps it, and an offering nobody recognises falls back to the baseline
- [x] Make entitlement expirable. `courseEntitlement` watches the store's own
      change stream, so a lapse locks the course with no restart
- [x] Answer an entitlement check with no network, from the last cached answer
- [x] Show the store's own price on the paywall and the gate sheet. This needed
      no work: `paywallViewProvider` already fetches the products and
      `paywall_view.dart` already substitutes `{price}` and `{perMonth}` — the
      rows drew blank only because the no-op store returns nothing
- [x] Add the Profile entry into the paywall, and a link out to Apple's
      manage-subscriptions screen
- [x] Ask the store which plan an owner holds, rather than remembering what
      this session bought, so it survives a restart or a change made elsewhere
- [ ] Enable the In-App Purchase capability — Xcode → Runner → Signing &
      Capabilities. `ios/Runner/Runner.entitlements` carries only
      associated-domains today
- [ ] Sandbox-test each arm: buy, restore on a fresh install, cancel, and let a
      subscription lapse
- [ ] Handle the edges: a purchase interrupted mid-flight, and one already made
      on this Apple Account. A store that cannot be reached is handled; the
      other two are only reachable in the sandbox

**Before submission:**

- [ ] Privacy policy and App Store privacy labels say that purchase data
      reaches RevenueCat
- [ ] On the two subscription arms, the price, the period and what renews are
      on screen at the buy button

## Status

The code is written and merged. What is left is an account, an Xcode
capability, and a sandbox that proves any of it works — the unticked boxes
above, owned by [#421](https://github.com/maximsan/brewpath/issues/421).

A build with no `REVENUECAT_KEY` still runs the no-op store, so the app is
free by construction until a key is passed.
