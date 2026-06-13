# Coffee Quest — Ads

## Current Status: Disabled for MVP

AdMob is **intentionally disabled** for MVP runtime (Phases 1–7).

- `google_mobile_ads` is **not** an active dependency in `pubspec.yaml`.
- `GADApplicationIdentifier` is **not** present in `ios/Runner/Info.plist`.
- No `MobileAds.instance.initialize()` call exists anywhere in the app.
- `lib/features/monetization/monetization_config.dart` holds a `kAdsEnabled = false` flag as a compile-safe placeholder.

---

## Future AdMob Setup

Steps to re-enable AdMob in Phase 8:

1. **Add dependency** — uncomment `google_mobile_ads` in `pubspec.yaml` and run `flutter pub get`.
2. **Add App ID to Info.plist** — add `GADApplicationIdentifier` with the AdMob App ID:
   ```xml
   <key>GADApplicationIdentifier</key>
   <string>ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX</string>
   ```
3. **Use Google test App ID during development** — `ca-app-pub-3940256099942544~3347511713` (iOS).  
   Switch to the real AdMob App ID only after the AdMob project is created in the console.
4. **Initialize in a dedicated bootstrap layer** — call `MobileAds.instance.initialize()` only inside `AdMobAdsService.initialize()`, never directly in `main.dart`.
5. **Guard behind config** — set `kAdsEnabled = true` in `monetization_config.dart` to activate the `AdMobAdsService` provider instead of `NoOpAdsService`.
6. **Implement ATT prompt** — present the App Tracking Transparency dialog (iOS 14+) before showing any ads.

> **ID format note:**  
> AdMob **App ID** always contains `~` (e.g. `ca-app-pub-XXXXXXXX~XXXXXXXX`).  
> AdMob **Ad Unit ID** always contains `/` (e.g. `ca-app-pub-XXXXXXXX/XXXXXXXX`).  
> They are different identifiers — do not confuse them.

---

## Policy

There are **no ads shown to users in MVP**. The ads layer exists only as a placeholder so ad monetization can be added later without architectural changes.

**Never show ads inside active lessons.** If ads are introduced, they go between modules or on voluntary rewarded placements only.

---

## AdsService Interface

```dart
// lib/services/ads/ads_service.dart

enum AdLoadStatus { loaded, failed, notAvailable }

abstract class AdsService {
  /// Initialize the ads SDK. Call once at app startup.
  Future<void> initialize();

  /// Load an interstitial ad (between-module placement).
  Future<AdLoadStatus> loadInterstitial(String adUnitId);

  /// Show a previously loaded interstitial.
  Future<void> showInterstitial();

  /// Load a rewarded ad.
  Future<AdLoadStatus> loadRewarded(String adUnitId);

  /// Show a rewarded ad. Returns true if user earned the reward.
  Future<bool> showRewarded();

  /// Dispose resources.
  void dispose();
}
```

---

## No-Op Implementation (MVP Active)

```dart
// lib/services/ads/noop_ads_service.dart
import '../../docs/ads_service.dart';

class NoOpAdsService implements AdsService {
  @override
  Future<void> initialize() async {}

  @override
  Future<AdLoadStatus> loadInterstitial(String adUnitId) async =>
      AdLoadStatus.notAvailable;

  @override
  Future<void> showInterstitial() async {}

  @override
  Future<AdLoadStatus> loadRewarded(String adUnitId) async =>
      AdLoadStatus.notAvailable;

  @override
  Future<bool> showRewarded() async => false;

  @override
  void dispose() {}
}
```

---

## AdMob Implementation Stub

```dart
// lib/services/ads/admob_ads_service.dart
// TODO: Implement using google_mobile_ads when ads go live.
//
// Key implementation steps (for future reference):
// 1. Call MobileAds.instance.initialize() in AdsService.initialize()
// 2. Use InterstitialAd.load() for interstitial ads
// 3. Use RewardedAd.load() for rewarded ads
// 4. Cache loaded ad instances — ads expire after ~1 hour
// 5. Set interstitialAd.fullScreenContentCallback for show/dismiss events
// 6. Pre-load next ad after current one is shown (keep pipeline filled)
// 7. Use test ad unit IDs during development (see AdMob docs)
//
// See: https://pub.dev/packages/google_mobile_ads

import '../../docs/ads_service.dart';

class AdMobAdsService implements AdsService {
  @override
  Future<void> initialize() => throw UnimplementedError('Implement when ads go live');

  @override
  Future<AdLoadStatus> loadInterstitial(String adUnitId) =>
      throw UnimplementedError();

  @override
  Future<void> showInterstitial() => throw UnimplementedError();

  @override
  Future<AdLoadStatus> loadRewarded(String adUnitId) =>
      throw UnimplementedError();

  @override
  Future<bool> showRewarded() => throw UnimplementedError();

  @override
  void dispose() {}
}
```

---

## Riverpod Provider

```dart
// lib/services/ads/ads_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../docs/ads_service.dart';
import '../../docs/noop_ads_service.dart';

part '../../docs/ads_provider.g.dart';

@riverpod
AdsService adsService(Ref ref) => NoOpAdsService();
// Swap to AdMobAdsService() when ads go live
```

---

## Ad Unit ID Constants

```dart
// lib/core/constants/ad_unit_ids.dart
// Use AdMob test ad unit IDs during development.

abstract class AdUnitIds {
  // Test IDs (iOS) — replace with real IDs from AdMob console before release
  static const String interstitialTest = 'ca-app-pub-3940256099942544/4411468910';
  static const String rewardedTest     = 'ca-app-pub-3940256099942544/1712485313';

  // Production IDs — fill in from AdMob console
  static const String interstitialProd = '';
  static const String rewardedProd     = '';
}
```

---

## Future Ad Placement Strategy

| Placement                                       | Type         | Trigger                                       |
| ----------------------------------------------- | ------------ | --------------------------------------------- |
| Between module completion and next module start | Interstitial | After module completion screen CTA            |
| Optional extra XP                               | Rewarded     | Button on Profile or lesson completion screen |
| Never inside an active lesson                   | —            | Hard rule                                     |
| Never on first launch                           | —            | User onboarding protection                    |

**No mediation in MVP.** AdMob direct fills are sufficient until significant DAU is reached.

---

## iOS Setup Requirements (For Future)

- [ ] Register app in AdMob console: [apps.admob.com](https://apps.admob.com)
- [ ] Add AdMob App ID to `ios/Runner/Info.plist`:
  ```xml
  <key>GADApplicationIdentifier</key>
  <string>ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX</string>
  ```
- [ ] Add SKAdNetwork identifiers to `Info.plist` (required for iOS 14+ attribution)
- [ ] Add `NSUserTrackingUsageDescription` to `Info.plist` (required for ATT prompt)
- [ ] Implement ATT (App Tracking Transparency) prompt before showing ads
- [ ] Use test ad unit IDs during development
- [ ] Switch to production ad unit IDs only in release builds

---

## Future Implementation Checklist

When ads are ready to go live:

- [ ] Register app in AdMob console and get a production App ID
- [ ] Add AdMob App ID to `ios/Runner/Info.plist`
- [ ] Implement ATT prompt (iOS 14+) in `app_bootstrap.dart`
- [ ] Replace `NoOpAdsService` with `AdMobAdsService` in `ads_provider.dart`
- [ ] Implement `AdMobAdsService.initialize()` calling `MobileAds.instance.initialize()`
- [ ] Implement interstitial and rewarded ad loading with caching
- [ ] Add interstitial call site after module completion (not inside lesson runner)
- [ ] Add rewarded ad option on Profile tab
- [ ] Test with test ad unit IDs on device (ads don't work on Simulator reliably)
- [ ] Switch to production ad unit IDs before release
- [ ] Verify ads never appear during active lesson steps

---

## Folder Structure

```
lib/services/ads/
├── ads_service.dart           # Abstract interface
├── noop_ads_service.dart      # MVP active implementation (no-op)
├── admob_ads_service.dart     # Future implementation stub
└── ads_provider.dart          # Riverpod provider

lib/core/constants/
└── ad_unit_ids.dart           # Ad unit ID constants
```

---

## Steps

- [x] Create `lib/services/ads/ads_service.dart`
- [x] Create `lib/services/ads/noop_ads_service.dart`
- [x] Create `lib/services/ads/admob_ads_service.dart`
- [x] Create `lib/services/ads/ads_provider.dart`
- [x] Create `lib/core/constants/ad_unit_ids.dart` with test IDs
- [x] Run `build_runner` to generate provider file
- [x] Verify `NoOpAdsService` is active in `ads_provider.dart`
- [x] Confirm no ads appear anywhere in the app during MVP testing

---

## Definition of Done

- [x] `AdsService` abstract interface exists
- [x] `NoOpAdsService` is the active provider in MVP
- [x] `AdMobAdsService` stub exists with `UnimplementedError` guards
- [x] `ads_provider.dart` compiles and resolves to `NoOpAdsService`
- [x] No ad banner, interstitial, or rewarded ad appears anywhere in MVP
- [x] Ad unit ID constants file exists with test IDs for future use
- [x] Future implementation checklist is complete and stored in this doc
