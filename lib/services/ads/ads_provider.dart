import 'package:brew_path/features/monetization/monetization_config.dart';
import 'package:brew_path/services/ads/admob_ads_service.dart';
import 'package:brew_path/services/ads/ads_service.dart';
import 'package:brew_path/services/ads/noop_ads_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ads_provider.g.dart';

/// Gated by `kAdsEnabled` (monetization_config.dart). Stays NoOp for the MVP;
/// flip the flag to activate AdMob once it's implemented.
@riverpod
AdsService adsService(Ref ref) =>
    kAdsEnabled ? AdMobAdsService() : const NoOpAdsService();
