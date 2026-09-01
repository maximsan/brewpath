import 'package:brew_path/features/dictionary/domain/dictionary_providers.dart';
import 'package:brew_path/features/dictionary/domain/flashcard_deck.dart';
import 'package:brew_path/features/monetization/domain/course_entitlement.dart';
import 'package:brew_path/features/saved/domain/saved_providers.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'flashcard_providers.g.dart';

/// The cards this learner would be dealt right now.
///
/// The deck is derived on every read from the saved keys and the learner's
/// reach, so un-saving a term takes it out of the deck with no second copy of
/// the set to keep in step. Every entry point reads this one provider — the
/// count on a chip and the cards in the drill must never disagree about what
/// is in the deck.
@riverpod
Future<List<DictionaryTerm>> flashcardDeck(Ref ref) async {
  // Every watch resolved before the first await: a rebuild mid-flight must
  // not find a watch on the far side of an async gap.
  final keys = ref.watch(savedKeysProvider.future);
  final view = ref.watch(dictionaryViewProvider.future);
  final entitlement = ref.watch(courseEntitlementProvider.future);

  final dictionary = await view;
  return deriveFlashcardDeck(
    savedKeys: await keys,
    accessibleIds: accessibleTermIds(
      dictionary.terms,
      completedLessonIds: dictionary.completedLessonIds,
      // Unresolved would read as free here, which is the wrong way to be
      // wrong: it would hide a payer's own saved terms from their own deck.
      // Awaited instead, so the deck is right the first time it is drawn.
      isPlus: await entitlement,
    ),
    terms: dictionary.terms,
  );
}

/// How many cards the deck holds — what the entry points count.
///
/// Off the deck rather than off the saved set: a chip reading `12` that opens
/// onto four cards is the promise this exists to keep.
@riverpod
Future<int> flashcardDeckSize(Ref ref) async =>
    (await ref.watch(flashcardDeckProvider.future)).length;
