// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'owned_term.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The term the learner currently holds, or null when they hold none.
///
/// Asked of the store, not of `PurchasedTerm`, which records only what *this
/// session* bought — so it survives a restart and a plan changed elsewhere.

@ProviderFor(ownedTerm)
final ownedTermProvider = OwnedTermProvider._();

/// The term the learner currently holds, or null when they hold none.
///
/// Asked of the store, not of `PurchasedTerm`, which records only what *this
/// session* bought — so it survives a restart and a plan changed elsewhere.

final class OwnedTermProvider
    extends
        $FunctionalProvider<
          AsyncValue<PlusTerm?>,
          PlusTerm?,
          FutureOr<PlusTerm?>
        >
    with $FutureModifier<PlusTerm?>, $FutureProvider<PlusTerm?> {
  /// The term the learner currently holds, or null when they hold none.
  ///
  /// Asked of the store, not of `PurchasedTerm`, which records only what *this
  /// session* bought — so it survives a restart and a plan changed elsewhere.
  OwnedTermProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ownedTermProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ownedTermHash();

  @$internal
  @override
  $FutureProviderElement<PlusTerm?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<PlusTerm?> create(Ref ref) {
    return ownedTerm(ref);
  }
}

String _$ownedTermHash() => r'154d353f9d32b7d57cb3f2a8d3e101971ca6fe63';
