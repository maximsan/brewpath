import 'package:coffee_quest/services/ads/ads_service.dart';

/// Active ads implementation for the MVP — never loads or shows anything.
class NoOpAdsService implements AdsService {
  /// Creates a [NoOpAdsService].
  const NoOpAdsService();

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
