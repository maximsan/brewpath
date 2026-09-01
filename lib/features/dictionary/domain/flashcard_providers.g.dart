// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flashcard_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The cards this learner would be dealt right now.
///
/// **The vocab game's saved pool, unchanged.** Both drills ask the same
/// question — *which terms may this learner practise?* — and
/// [ADR-0014](../../../../docs/adr/0014-a-practice-pool-is-the-terms-the-tier-can-reach.md)
/// answers it once: accessible ∩ saved, tier-scoped, in bank order. Deriving
/// it a second time here is how the two drills would come to disagree about a
/// free learner's own shelf.
///
/// Named for what this screen calls it, because "the deck" is the word the
/// drill and its three entry points use.

@ProviderFor(flashcardDeck)
final flashcardDeckProvider = FlashcardDeckProvider._();

/// The cards this learner would be dealt right now.
///
/// **The vocab game's saved pool, unchanged.** Both drills ask the same
/// question — *which terms may this learner practise?* — and
/// [ADR-0014](../../../../docs/adr/0014-a-practice-pool-is-the-terms-the-tier-can-reach.md)
/// answers it once: accessible ∩ saved, tier-scoped, in bank order. Deriving
/// it a second time here is how the two drills would come to disagree about a
/// free learner's own shelf.
///
/// Named for what this screen calls it, because "the deck" is the word the
/// drill and its three entry points use.

final class FlashcardDeckProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DictionaryTerm>>,
          List<DictionaryTerm>,
          FutureOr<List<DictionaryTerm>>
        >
    with
        $FutureModifier<List<DictionaryTerm>>,
        $FutureProvider<List<DictionaryTerm>> {
  /// The cards this learner would be dealt right now.
  ///
  /// **The vocab game's saved pool, unchanged.** Both drills ask the same
  /// question — *which terms may this learner practise?* — and
  /// [ADR-0014](../../../../docs/adr/0014-a-practice-pool-is-the-terms-the-tier-can-reach.md)
  /// answers it once: accessible ∩ saved, tier-scoped, in bank order. Deriving
  /// it a second time here is how the two drills would come to disagree about a
  /// free learner's own shelf.
  ///
  /// Named for what this screen calls it, because "the deck" is the word the
  /// drill and its three entry points use.
  FlashcardDeckProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'flashcardDeckProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$flashcardDeckHash();

  @$internal
  @override
  $FutureProviderElement<List<DictionaryTerm>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DictionaryTerm>> create(Ref ref) {
    return flashcardDeck(ref);
  }
}

String _$flashcardDeckHash() => r'9cd150e7e325e08d4a92002b02fee33d80d990d3';

/// How many cards the deck holds — what the entry points count.
///
/// Off the deck rather than off the saved set: a chip reading `12` that opens
/// onto four is the promise this exists to keep.

@ProviderFor(flashcardDeckSize)
final flashcardDeckSizeProvider = FlashcardDeckSizeProvider._();

/// How many cards the deck holds — what the entry points count.
///
/// Off the deck rather than off the saved set: a chip reading `12` that opens
/// onto four is the promise this exists to keep.

final class FlashcardDeckSizeProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// How many cards the deck holds — what the entry points count.
  ///
  /// Off the deck rather than off the saved set: a chip reading `12` that opens
  /// onto four is the promise this exists to keep.
  FlashcardDeckSizeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'flashcardDeckSizeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$flashcardDeckSizeHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return flashcardDeckSize(ref);
  }
}

String _$flashcardDeckSizeHash() => r'667c1e4b626c1e2db8dabca5f0d1be06dc32a705';
