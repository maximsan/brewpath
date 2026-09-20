# BrewPath — Ads

AdMob is **disabled**. No ads are shown, and the layer exists only so ad
monetization can be added later without architectural change:
`google_mobile_ads` is not a dependency, `GADApplicationIdentifier` is not in
`Info.plist`, and `kAdsEnabled = false` in
`lib/features/monetization/monetization_config.dart` is the compile-safe
placeholder.

## Policy

**Never show ads inside active lessons.** If ads are introduced, they go
between modules or on voluntary rewarded placements only, and never on first
launch.

## Where the code is

The interface and its implementations are the source; this doc does not
restate them.

```
lib/services/ads/
├── ads_service.dart           # the interface, and AdLoadStatus
├── noop_ads_service.dart      # active: loads nothing, shows nothing
├── admob_ads_service.dart     # the future implementation, every method unimplemented
└── ads_provider.dart          # resolves to the no-op; swaps when ads go live

lib/core/constants/
└── ad_unit_ids.dart           # Google's iOS test unit ids; production ids empty
```

## Going live

1. Add `google_mobile_ads` to `pubspec.yaml`.
2. Register the app in the [AdMob console](https://apps.admob.com) and put
   the App ID in `ios/Runner/Info.plist` as `GADApplicationIdentifier`. Until
   the console project exists, use Google's test App ID
   `ca-app-pub-3940256099942544~3347511713`. An App ID contains `~`; an ad
   unit id contains `/` — they are different identifiers.
3. Add the SKAdNetwork identifiers and `NSUserTrackingUsageDescription` to
   `Info.plist`, and present the App Tracking Transparency prompt before any
   ad (iOS 14+).
4. Implement `AdMobAdsService`: `MobileAds.instance.initialize()` inside its
   own `initialize()`, never in `main.dart`; `InterstitialAd.load()` and
   `RewardedAd.load()`; cache loaded ads, which expire after about an hour,
   and preload the next after a show; `fullScreenContentCallback` for show
   and dismiss.
5. Set `kAdsEnabled = true`, so the provider resolves to `AdMobAdsService`.
6. Add the call sites — an interstitial after the module ending's CTA, a
   rewarded option on Profile — and test on a device with the test unit ids;
   the simulator is unreliable. Production ids in release builds only.

## Placement — speculative

> ⚠️ **No ruling behind this table.** `docs/decisions.md` has no ads decision,
> and a rewarded-points path would interact with the daily cap and the streak
> economy (§8–§10) in ways nobody has ruled on. Decide there first.

| Placement                                       | Type         | Trigger                                       |
| ----------------------------------------------- | ------------ | --------------------------------------------- |
| Between module completion and next module start | Interstitial | After module completion screen CTA            |
| Optional extra points                           | Rewarded     | Button on Profile or lesson completion screen |
| Never inside an active lesson                   | —            | Hard rule                                     |
| Never on first launch                           | —            | User onboarding protection                    |

No mediation until there is meaningful DAU; AdMob direct fills suffice.
