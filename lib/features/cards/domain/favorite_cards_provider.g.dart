// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_cards_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// In-memory set of favorited card IDs.
/// Phase B keeps this in memory only;
/// Phase A backs it with Drift so favorites survive a restart.

@ProviderFor(FavoriteCards)
final favoriteCardsProvider = FavoriteCardsProvider._();

/// In-memory set of favorited card IDs.
/// Phase B keeps this in memory only;
/// Phase A backs it with Drift so favorites survive a restart.
final class FavoriteCardsProvider
    extends $NotifierProvider<FavoriteCards, Set<String>> {
  /// In-memory set of favorited card IDs.
  /// Phase B keeps this in memory only;
  /// Phase A backs it with Drift so favorites survive a restart.
  FavoriteCardsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favoriteCardsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favoriteCardsHash();

  @$internal
  @override
  FavoriteCards create() => FavoriteCards();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$favoriteCardsHash() => r'85779f39d3a950074a09ad32f9563e233a427922';

/// In-memory set of favorited card IDs.
/// Phase B keeps this in memory only;
/// Phase A backs it with Drift so favorites survive a restart.

abstract class _$FavoriteCards extends $Notifier<Set<String>> {
  Set<String> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Set<String>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<String>, Set<String>>,
              Set<String>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
