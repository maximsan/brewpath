// Future implementation stub. Intentionally does NOT import
// `google_mobile_ads` yet — wired up only when ads go live, behind
// `kAdsEnabled` in lib/features/monetization/monetization_config.dart.
// The implementation steps are in docs/ads.md.

import 'package:brew_path/services/ads/ads_service.dart';

/// Real [AdsService] backed by AdMob (stubbed for now; see docs/ads.md).
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
