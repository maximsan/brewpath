import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:coffee_quest/features/monetization/monetization_config.dart';
import 'package:coffee_quest/services/ads/admob_ads_service.dart';
import 'package:coffee_quest/services/ads/ads_service.dart';
import 'package:coffee_quest/services/ads/noop_ads_service.dart';

part 'ads_provider.g.dart';

/// Gated by `kAdsEnabled` (monetization_config.dart). Stays NoOp for the MVP;
/// flip the flag to activate AdMob once it's implemented.
@riverpod
AdsService adsService(Ref ref) =>
    kAdsEnabled ? AdMobAdsService() : const NoOpAdsService();
