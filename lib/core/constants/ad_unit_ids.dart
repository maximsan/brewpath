// Self-describing tokens / DTOs / storage infra; no per-member docs.
// ignore_for_file: public_member_api_docs

/// AdMob ad unit IDs. Use the test IDs during development; fill in the
/// production IDs from the AdMob console before release.
///
/// Note: an AdMob **App ID** contains `~`; an **Ad Unit ID** contains `/`.
abstract class AdUnitIds {
  // Test IDs (iOS) — Google's public test units.
  static const String interstitialTest =
      'ca-app-pub-3940256099942544/4411468910';
  static const String rewardedTest = 'ca-app-pub-3940256099942544/1712485313';

  // Production IDs — fill in from the AdMob console before release.
  static const String interstitialProd = '';
  static const String rewardedProd = '';
}
