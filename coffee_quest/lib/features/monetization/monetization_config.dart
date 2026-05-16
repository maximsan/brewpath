// Ads and monetization are intentionally disabled for MVP (Phase 1–7).
// Phase 8 activates AdMob — see docs/11-ads.md for the full integration plan.
//
// DO NOT import google_mobile_ads here until Phase 8.
// DO NOT call MobileAds.instance.initialize() outside a dedicated ads bootstrap.

/// Whether ads are enabled in the current build.
///
/// Guarded by this flag so call sites compile cleanly before Phase 8.
const bool kAdsEnabled = false;
