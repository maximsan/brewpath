// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payments_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the active [PaymentsService] — No-Op until payments go live.

@ProviderFor(paymentsService)
final paymentsServiceProvider = PaymentsServiceProvider._();

/// Provides the active [PaymentsService] — No-Op until payments go live.

final class PaymentsServiceProvider
    extends
        $FunctionalProvider<PaymentsService, PaymentsService, PaymentsService>
    with $Provider<PaymentsService> {
  /// Provides the active [PaymentsService] — No-Op until payments go live.
  PaymentsServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paymentsServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paymentsServiceHash();

  @$internal
  @override
  $ProviderElement<PaymentsService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PaymentsService create(Ref ref) {
    return paymentsService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PaymentsService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PaymentsService>(value),
    );
  }
}

String _$paymentsServiceHash() => r'538e4d386eea1b852056a9a3cbc7fdcbebcf1166';
