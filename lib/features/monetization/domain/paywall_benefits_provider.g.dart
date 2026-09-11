// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paywall_benefits_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The paywall's benefit rows, counted from the shipped banks.

@ProviderFor(paywallBenefits)
final paywallBenefitsProvider = PaywallBenefitsProvider._();

/// The paywall's benefit rows, counted from the shipped banks.

final class PaywallBenefitsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PaywallBenefit>>,
          List<PaywallBenefit>,
          FutureOr<List<PaywallBenefit>>
        >
    with
        $FutureModifier<List<PaywallBenefit>>,
        $FutureProvider<List<PaywallBenefit>> {
  /// The paywall's benefit rows, counted from the shipped banks.
  PaywallBenefitsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paywallBenefitsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paywallBenefitsHash();

  @$internal
  @override
  $FutureProviderElement<List<PaywallBenefit>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PaywallBenefit>> create(Ref ref) {
    return paywallBenefits(ref);
  }
}

String _$paywallBenefitsHash() => r'8da5849061b092938a2e3ddcce0335a20382e696';
