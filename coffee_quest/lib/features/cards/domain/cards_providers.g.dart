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
