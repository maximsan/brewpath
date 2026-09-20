// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cards_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Every card the bank holds, paired with whether the learner owns it.
///
/// Reads the collected ids off the snapshot, which follows the database on its
/// own, so collecting a card reaches every surface showing one (ADR-0031).

@ProviderFor(cardsWithCollection)
final cardsWithCollectionProvider = CardsWithCollectionProvider._();

/// Every card the bank holds, paired with whether the learner owns it.
///
/// Reads the collected ids off the snapshot, which follows the database on its
/// own, so collecting a card reaches every surface showing one (ADR-0031).

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
  /// Reads the collected ids off the snapshot, which follows the database on its
  /// own, so collecting a card reaches every surface showing one (ADR-0031).
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
    r'e0bd3edaf475fd0f677e45ef9815142095557f04';
