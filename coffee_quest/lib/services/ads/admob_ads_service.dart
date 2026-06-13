// Future implementation stub. Intentionally does NOT import
// `google_mobile_ads` yet — wired up only when ads go live
// (see docs/11-ads.md). Activated via `kAdsEnabled` in
// lib/features/monetization/monetization_config.dart.
//
// Implementation steps (future):
// 1. MobileAds.instance.initialize() in initialize()
// 2. InterstitialAd.load() / RewardedAd.load()
// 3. Cache loaded ads (they expire ~1h); preload the next after show
// 4. fullScreenContentCallback for show/dismiss events
// 5. Test ad unit IDs in dev; ATT prompt before any ad on iOS 14+

import 'package:coffee_quest/services/ads/ads_service.dart';

/// Real [AdsService] backed by AdMob (stubbed for now; see docs/11-ads.md).
class AdMobAdsService implements AdsService {
  @override
  Future<void> initialize() =>
      throw UnimplementedError('Implement when ads go live');

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
