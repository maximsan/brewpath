// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flashcard_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The cards this learner would be dealt right now.
///
/// The deck is derived on every read from the saved keys and the learner's
/// reach, so un-saving a term takes it out of the deck with no second copy of
/// the set to keep in step. Every entry point reads this one provider — the
/// count on a chip and the cards in the drill must never disagree about what
/// is in the deck.

@ProviderFor(flashcardDeck)
final flashcardDeckProvider = FlashcardDeckProvider._();

/// The cards this learner would be dealt right now.
///
/// The deck is derived on every read from the saved keys and the learner's
/// reach, so un-saving a term takes it out of the deck with no second copy of
/// the set to keep in step. Every entry point reads this one provider — the
/// count on a chip and the cards in the drill must never disagree about what
/// is in the deck.

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
  /// The deck is derived on every read from the saved keys and the learner's
  /// reach, so un-saving a term takes it out of the deck with no second copy of
  /// the set to keep in step. Every entry point reads this one provider — the
  /// count on a chip and the cards in the drill must never disagree about what
  /// is in the deck.
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

String _$flashcardDeckHash() => r'f5ec5b885faff3349ea27b6150f75a3d16193168';

/// How many cards the deck holds — what the entry points count.
///
/// Off the deck rather than off the saved set: a chip reading `12` that opens
/// onto four cards is the promise this exists to keep.

@ProviderFor(flashcardDeckSize)
final flashcardDeckSizeProvider = FlashcardDeckSizeProvider._();

/// How many cards the deck holds — what the entry points count.
///
/// Off the deck rather than off the saved set: a chip reading `12` that opens
/// onto four cards is the promise this exists to keep.

final class FlashcardDeckSizeProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// How many cards the deck holds — what the entry points count.
  ///
  /// Off the deck rather than off the saved set: a chip reading `12` that opens
  /// onto four cards is the promise this exists to keep.
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
