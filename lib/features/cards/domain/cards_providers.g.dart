// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cards_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Reads collected IDs from `cardRepositoryProvider` directly rather than
/// chaining through `collectedCardsProvider.future`. The chained form hits a
/// Riverpod 3.2.1 internal-pause-state assertion (issue #4709) when the
/// `StatefulShellRoute` toggles `TickerMode` after the lesson-completion
/// screen invalidates the inner provider. Callers that mutate collected
/// cards must invalidate this provider alongside `collectedCardsProvider`.

@ProviderFor(cardsWithCollection)
final cardsWithCollectionProvider = CardsWithCollectionProvider._();

/// Reads collected IDs from `cardRepositoryProvider` directly rather than
/// chaining through `collectedCardsProvider.future`. The chained form hits a
/// Riverpod 3.2.1 internal-pause-state assertion (issue #4709) when the
/// `StatefulShellRoute` toggles `TickerMode` after the lesson-completion
/// screen invalidates the inner provider. Callers that mutate collected
/// cards must invalidate this provider alongside `collectedCardsProvider`.

final class CardsWithCollectionProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CardWithCollection>>,
          List<CardWithCollection>,
          FutureOr<List<CardWithCollection>>
        >
    with
        $FutureModifier<List<CardWithCollection>>,
        $FutureProvider<List<CardWithCollection>> {
  /// Reads collected IDs from `cardRepositoryProvider` directly rather than
  /// chaining through `collectedCardsProvider.future`. The chained form hits a
  /// Riverpod 3.2.1 internal-pause-state assertion (issue #4709) when the
  /// `StatefulShellRoute` toggles `TickerMode` after the lesson-completion
  /// screen invalidates the inner provider. Callers that mutate collected
  /// cards must invalidate this provider alongside `collectedCardsProvider`.
  CardsWithCollectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cardsWithCollectionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cardsWithCollectionHash();

  @$internal
  @override
  $FutureProviderElement<List<CardWithCollection>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CardWithCollection>> create(Ref ref) {
    return cardsWithCollection(ref);
  }
}

String _$cardsWithCollectionHash() =>
    r'e90b2194edb08dcedb9d9014f5086725bf05c085';

/// Watches two things: ref.watch(favoriteCardsProvider) (the Set<String>)
/// and ref.watch(contentRepositoryProvider).getCards() (the card content).
/// Returns Future<List<CoffeeCardModel>> —
/// the cards whose id is in the favorites set.

@ProviderFor(favoriteCardsList)
final favoriteCardsListProvider = FavoriteCardsListProvider._();

/// Watches two things: ref.watch(favoriteCardsProvider) (the Set<String>)
/// and ref.watch(contentRepositoryProvider).getCards() (the card content).
/// Returns Future<List<CoffeeCardModel>> —
/// the cards whose id is in the favorites set.

final class FavoriteCardsListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CoffeeCardModel>>,
          List<CoffeeCardModel>,
          FutureOr<List<CoffeeCardModel>>
        >
    with
        $FutureModifier<List<CoffeeCardModel>>,
        $FutureProvider<List<CoffeeCardModel>> {
  /// Watches two things: ref.watch(favoriteCardsProvider) (the Set<String>)
  /// and ref.watch(contentRepositoryProvider).getCards() (the card content).
  /// Returns Future<List<CoffeeCardModel>> —
  /// the cards whose id is in the favorites set.
  FavoriteCardsListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favoriteCardsListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favoriteCardsListHash();

  @$internal
  @override
  $FutureProviderElement<List<CoffeeCardModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CoffeeCardModel>> create(Ref ref) {
    return favoriteCardsList(ref);
  }
}

String _$favoriteCardsListHash() => r'172ed916dc81cd10f32063bedb6426795d433826';

/// Returns first equal card by Id

@ProviderFor(cardById)
final cardByIdProvider = CardByIdFamily._();

/// Returns first equal card by Id

final class CardByIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<CoffeeCardModel?>,
          CoffeeCardModel?,
          FutureOr<CoffeeCardModel?>
        >
    with $FutureModifier<CoffeeCardModel?>, $FutureProvider<CoffeeCardModel?> {
  /// Returns first equal card by Id
  CardByIdProvider._({
    required CardByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'cardByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$cardByIdHash();

  @override
  String toString() {
    return r'cardByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<CoffeeCardModel?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CoffeeCardModel?> create(Ref ref) {
    final argument = this.argument as String;
    return cardById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CardByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$cardByIdHash() => r'aed02080a5b28c0c8812171f24d85e8ebbec072c';

/// Returns first equal card by Id

final class CardByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<CoffeeCardModel?>, String> {
  CardByIdFamily._()
    : super(
        retry: null,
        name: r'cardByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Returns first equal card by Id

  CardByIdProvider call(String cardId) =>
      CardByIdProvider._(argument: cardId, from: this);

  @override
  String toString() => r'cardByIdProvider';
}
