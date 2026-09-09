// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cards_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Every card the bank holds, paired with whether the learner owns it.
///
/// Reads the collected ids **off the snapshot directly** rather than chaining
/// through another provider: the chained form hit a Riverpod 3.2.1
/// internal-pause-state assertion (issue #4709) when the `StatefulShellRoute`
/// toggled `TickerMode` after a lesson completion invalidated the inner one.

@ProviderFor(cardsWithCollection)
final cardsWithCollectionProvider = CardsWithCollectionProvider._();

/// Every card the bank holds, paired with whether the learner owns it.
///
/// Reads the collected ids **off the snapshot directly** rather than chaining
/// through another provider: the chained form hit a Riverpod 3.2.1
/// internal-pause-state assertion (issue #4709) when the `StatefulShellRoute`
/// toggled `TickerMode` after a lesson completion invalidated the inner one.

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
  /// Every card the bank holds, paired with whether the learner owns it.
  ///
  /// Reads the collected ids **off the snapshot directly** rather than chaining
  /// through another provider: the chained form hit a Riverpod 3.2.1
  /// internal-pause-state assertion (issue #4709) when the `StatefulShellRoute`
  /// toggled `TickerMode` after a lesson completion invalidated the inner one.
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
    r'5bfcb4fda5637fecf1d244b5ff0f265b1d5a6995';

/// How many of the five Module Rewards the learner owns.
///
/// Chained through [cardsWithCollection] rather than reading the snapshot
/// again, so the callers that already refresh the grid refresh this too and
/// there is no third provider for a mutation site to forget.

@ProviderFor(collectedModuleRewards)
final collectedModuleRewardsProvider = CollectedModuleRewardsProvider._();

/// How many of the five Module Rewards the learner owns.
///
/// Chained through [cardsWithCollection] rather than reading the snapshot
/// again, so the callers that already refresh the grid refresh this too and
/// there is no third provider for a mutation site to forget.

final class CollectedModuleRewardsProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// How many of the five Module Rewards the learner owns.
  ///
  /// Chained through [cardsWithCollection] rather than reading the snapshot
  /// again, so the callers that already refresh the grid refresh this too and
  /// there is no third provider for a mutation site to forget.
  CollectedModuleRewardsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'collectedModuleRewardsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$collectedModuleRewardsHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return collectedModuleRewards(ref);
  }
}

String _$collectedModuleRewardsHash() =>
    r'd0a78eeade4551f94c3a30d2ca39e4eeab8aa8ea';
