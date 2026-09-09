// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cards_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Every card the bank holds, paired with whether the learner owns it.
///
/// Reads the collected ids **off the snapshot directly**: chaining through a
/// provider hit a Riverpod 3.2.1 pause-state assertion (issue #4709) under the
/// `StatefulShellRoute`. So a caller that collects a card invalidates this,
/// and everything showing a collection hangs off it.

@ProviderFor(cardsWithCollection)
final cardsWithCollectionProvider = CardsWithCollectionProvider._();

/// Every card the bank holds, paired with whether the learner owns it.
///
/// Reads the collected ids **off the snapshot directly**: chaining through a
/// provider hit a Riverpod 3.2.1 pause-state assertion (issue #4709) under the
/// `StatefulShellRoute`. So a caller that collects a card invalidates this,
/// and everything showing a collection hangs off it.

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
  /// Reads the collected ids **off the snapshot directly**: chaining through a
  /// provider hit a Riverpod 3.2.1 pause-state assertion (issue #4709) under the
  /// `StatefulShellRoute`. So a caller that collects a card invalidates this,
  /// and everything showing a collection hangs off it.
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
