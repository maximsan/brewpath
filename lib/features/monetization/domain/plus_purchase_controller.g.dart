// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plus_purchase_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drives the sheet's one action, and nothing else.
///
/// Holds no rule about what Plus contains and never reads a store SDK — it
/// calls [PaymentsService] and re-reads [courseEntitlementProvider] when the
/// answer may have changed, which is what makes the surfaces behind the sheet
/// update without knowing a purchase happened.

@ProviderFor(PlusPurchase)
final plusPurchaseProvider = PlusPurchaseProvider._();

/// Drives the sheet's one action, and nothing else.
///
/// Holds no rule about what Plus contains and never reads a store SDK — it
/// calls [PaymentsService] and re-reads [courseEntitlementProvider] when the
/// answer may have changed, which is what makes the surfaces behind the sheet
/// update without knowing a purchase happened.
final class PlusPurchaseProvider
    extends $NotifierProvider<PlusPurchase, PlusPurchaseState> {
  /// Drives the sheet's one action, and nothing else.
  ///
  /// Holds no rule about what Plus contains and never reads a store SDK — it
  /// calls [PaymentsService] and re-reads [courseEntitlementProvider] when the
  /// answer may have changed, which is what makes the surfaces behind the sheet
  /// update without knowing a purchase happened.
  PlusPurchaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'plusPurchaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$plusPurchaseHash();

  @$internal
  @override
  PlusPurchase create() => PlusPurchase();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlusPurchaseState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlusPurchaseState>(value),
    );
  }
}

String _$plusPurchaseHash() => r'd88c59afb0e00be299f36c7a2ef1e6810bb29474';

/// Drives the sheet's one action, and nothing else.
///
/// Holds no rule about what Plus contains and never reads a store SDK — it
/// calls [PaymentsService] and re-reads [courseEntitlementProvider] when the
/// answer may have changed, which is what makes the surfaces behind the sheet
/// update without knowing a purchase happened.

abstract class _$PlusPurchase extends $Notifier<PlusPurchaseState> {
  PlusPurchaseState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<PlusPurchaseState, PlusPurchaseState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PlusPurchaseState, PlusPurchaseState>,
              PlusPurchaseState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
