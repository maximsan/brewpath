// The Misses deck end to end through the provider: what the drill writes is
// what the setup screen offers. The pieces either side are unit-tested on
// their own; this asserts they are actually joined up.
import 'package:brew_path/features/dictionary/domain/vocab_miss_log.dart';
import 'package:brew_path/features/dictionary/domain/vocab_pool.dart';
import 'package:brew_path/features/dictionary/domain/vocab_providers.dart';
import 'package:brew_path/features/dictionary/domain/vocab_setup.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:brew_path/shared/repositories/dictionary_repository.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/widget_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// The terms a free learner — the shipped state — can be drilled on.
  late List<DictionaryTerm> accessible;
  final answeredAt = DateTime(2026, 9, 1, 10);

  setUpAll(() async {
    accessible = accessibleTerms(
      terms: await DictionaryRepository().getTerms(),
      lessons: await ContentRepository().getLessons(),
      hasCourse: false,
    );
  });

  late ProviderContainer container;
  late VocabMissLog log;

  setUp(() async {
    await useInMemoryDatabase();
    container = ProviderContainer();
    addTearDown(container.dispose);
    // Held for the whole test: the pools provider auto-disposes, and the
    // entitlement resolving mid-build would otherwise drop it before the
    // future it was read through ever completes.
    addTearDown(container.listen(vocabPoolsProvider, (_, _) {}).close);
    log = VocabMissLog(container.read(snapshotRepositoryProvider));
  });

  /// The pools as they stand *now*, refreshed the way the drill refreshes
  /// them: the answers are invalidated and the pools follow.
  Future<VocabPools> pools() {
    container.invalidate(vocabAnswersProvider);
    return container.read(vocabPoolsProvider.future);
  }

  Future<void> answer(
    DictionaryTerm term, {
    required bool correct,
    int secondsIn = 0,
  }) => log.record(
    termId: term.id,
    correct: correct,
    now: answeredAt.add(Duration(seconds: secondsIn)),
  );

  test('a fresh learner owes no reviews, so the deck is not offered', () async {
    final fresh = await pools();

    expect(fresh.missed, isEmpty);
    expect(vocabDeckAvailable(fresh.missed.length), isFalse);
  });

  test('four wrong answers open the deck at four', () async {
    // The acceptance case, from either end: the drill writes, the setup
    // screen reads, and the minimum is the Saved deck's.
    for (final term in accessible.take(vocabMinimumPool)) {
      await answer(term, correct: false);
    }

    final after = await pools();

    expect(after.missed, hasLength(vocabMinimumPool));
    expect(vocabDeckAvailable(after.missed.length), isTrue);
    expect(after.forDeck(VocabDeck.misses), after.missed);
  });

  test('one correct answer drops it below the minimum, back to All', () async {
    final missed = accessible.take(vocabMinimumPool).toList();
    for (final term in missed) {
      await answer(term, correct: false);
    }
    await answer(missed.first, correct: true, secondsIn: 30);

    final after = await pools();

    expect(after.missed, hasLength(vocabMinimumPool - 1));
    expect(
      resolveVocabDeck(
        chosen: VocabDeck.misses,
        chosenPoolSize: after.missed.length,
      ),
      VocabDeck.all,
    );
  });

  test('the deck holds only what is still owed, in bank order', () async {
    final missed = accessible.take(vocabMinimumPool).toList();
    for (final term in missed) {
      await answer(term, correct: false);
    }
    await answer(missed[1], correct: true, secondsIn: 30);

    final after = await pools();

    expect(
      after.missed.map((term) => term.id),
      [missed[0].id, missed[2].id, missed[3].id],
    );
  });
}
