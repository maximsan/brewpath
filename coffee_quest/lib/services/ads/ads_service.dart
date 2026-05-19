enum AdLoadStatus { loaded, failed, notAvailable }

/// Abstract ads layer. No feature code touches `google_mobile_ads` directly —
/// only this interface. NoOp is active in the MVP; ads never appear in
/// lessons (hard rule, see docs/11-ads.md).
abstract class AdsService {
  /// Initialize the ads SDK. Call once at app startup.
  Future<void> initialize();

  /// Load an interstitial ad (between-module placement).
  Future<AdLoadStatus> loadInterstitial(String adUnitId);

  /// Show a previously loaded interstitial.
  Future<void> showInterstitial();

  /// Load a rewarded ad.
  Future<AdLoadStatus> loadRewarded(String adUnitId);

  /// Show a rewarded ad. Returns true if the user earned the reward.
  Future<bool> showRewarded();

  /// Dispose resources.
  void dispose();
}
