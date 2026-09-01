import 'package:brew_path/features/dictionary/domain/vocab_providers.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'flashcard_providers.g.dart';

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
@riverpod
Future<List<DictionaryTerm>> flashcardDeck(Ref ref) async =>
    (await ref.watch(vocabPoolsProvider.future)).saved;

/// How many cards the deck holds — what the entry points count.
///
/// Off the deck rather than off the saved set: a chip reading `12` that opens
/// onto four is the promise this exists to keep.
@riverpod
Future<int> flashcardDeckSize(Ref ref) async =>
    (await ref.watch(flashcardDeckProvider.future)).length;
