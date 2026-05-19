// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ads_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Gated by `kAdsEnabled` (monetization_config.dart). Stays NoOp for the MVP;
/// flip the flag to activate AdMob once it's implemented.

@ProviderFor(adsService)
final adsServiceProvider = AdsServiceProvider._();

/// Gated by `kAdsEnabled` (monetization_config.dart). Stays NoOp for the MVP;
/// flip the flag to activate AdMob once it's implemented.

final class AdsServiceProvider
    extends $FunctionalProvider<AdsService, AdsService, AdsService>
    with $Provider<AdsService> {
  /// Gated by `kAdsEnabled` (monetization_config.dart). Stays NoOp for the MVP;
  /// flip the flag to activate AdMob once it's implemented.
  AdsServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adsServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adsServiceHash();

  @$internal
  @override
  $ProviderElement<AdsService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AdsService create(Ref ref) {
    return adsService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AdsService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AdsService>(value),
    );
  }
}

String _$adsServiceHash() => r'5414f46b9b20d67c69b40467e6593936bbee3b97';
