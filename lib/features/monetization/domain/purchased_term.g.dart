// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchased_term.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The term of the plan this session just bought, so the welcome can say
/// what was bought; null until a purchase lands. Kept alive because the
/// welcome is read after the paywall that recorded it is gone.

@ProviderFor(PurchasedTerm)
final purchasedTermProvider = PurchasedTermProvider._();

/// The term of the plan this session just bought, so the welcome can say
/// what was bought; null until a purchase lands. Kept alive because the
/// welcome is read after the paywall that recorded it is gone.
final class PurchasedTermProvider
    extends $NotifierProvider<PurchasedTerm, PlusTerm?> {
  /// The term of the plan this session just bought, so the welcome can say
  /// what was bought; null until a purchase lands. Kept alive because the
  /// welcome is read after the paywall that recorded it is gone.
  PurchasedTermProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'purchasedTermProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$purchasedTermHash();

  @$internal
  @override
  PurchasedTerm create() => PurchasedTerm();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlusTerm? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlusTerm?>(value),
    );
  }
}

String _$purchasedTermHash() => r'f532829c72148cb3ea7bcf421875ac821a136a6e';

/// The term of the plan this session just bought, so the welcome can say
/// what was bought; null until a purchase lands. Kept alive because the
/// welcome is read after the paywall that recorded it is gone.

abstract class _$PurchasedTerm extends $Notifier<PlusTerm?> {
  PlusTerm? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<PlusTerm?, PlusTerm?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PlusTerm?, PlusTerm?>,
              PlusTerm?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
