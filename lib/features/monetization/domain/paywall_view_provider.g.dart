// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paywall_view_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// What the paywall draws: the arm's own words, with the store's prices in.
///
/// The store is asked only for the SKUs this arm sells, so an arm nobody is
/// on costs no round trip.

@ProviderFor(paywallView)
final paywallViewProvider = PaywallViewProvider._();

/// What the paywall draws: the arm's own words, with the store's prices in.
///
/// The store is asked only for the SKUs this arm sells, so an arm nobody is
/// on costs no round trip.

final class PaywallViewProvider
    extends
        $FunctionalProvider<
          AsyncValue<PaywallView>,
          PaywallView,
          FutureOr<PaywallView>
        >
    with $FutureModifier<PaywallView>, $FutureProvider<PaywallView> {
  /// What the paywall draws: the arm's own words, with the store's prices in.
  ///
  /// The store is asked only for the SKUs this arm sells, so an arm nobody is
  /// on costs no round trip.
  PaywallViewProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paywallViewProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paywallViewHash();

  @$internal
  @override
  $FutureProviderElement<PaywallView> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PaywallView> create(Ref ref) {
    return paywallView(ref);
  }
}

String _$paywallViewHash() => r'81210805b3c613871a2b92c92ada190c09416979';
