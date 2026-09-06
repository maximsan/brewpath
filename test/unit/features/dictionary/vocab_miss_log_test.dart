// What answering a question writes down. The Misses deck's rule — wrong adds,
// right clears, in any deck — is the snapshot scope's; this asserts the drill
// goes through it, and that answers landing faster than writes do not lose one
// of themselves.
import 'package:brew_path/features/dictionary/domain/vocab_miss_log.dart';
import 'package:brew_path/shared/repositories/snapshot_repository.dart';
import 'package:brew_path/shared/storage/app_database.dart';
import 'package:brew_path/shared/storage/snapshot/term_miss.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late SnapshotRepository repo;
  late VocabMissLog log;
  final answeredAt = DateTime(2026, 9, 1, 10);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    AppDatabaseService.instance = db;
    repo = SnapshotRepository();
    log = VocabMissLog(repo);
  });
  tearDown(() async => db.close());

  Future<Map<String, TermMiss>> misses() async =>
      (await repo.read()).clearedByReset.termAnswers;

  test('a wrong answer puts the term in the deck', () async {
    await log.record(termId: 'crema', correct: false, now: answeredAt);

    expect((await misses())['crema']!.isMissed, isTrue);
  });

  test('a correct answer on the same term takes it out', () async {
    await log.record(termId: 'crema', correct: false, now: answeredAt);
    await log.record(
      termId: 'crema',
      correct: true,
      now: answeredAt.add(const Duration(seconds: 30)),
    );

    expect((await misses())['crema']!.isMissed, isFalse);
  });

  test(
    'a correct answer is recorded even for a term never missed here',
    () async {
      // It has to be: the other device may hold a miss this one has not seen,
      // and a clear it cannot out-stamp is a clear that never happens.
      await log.record(termId: 'tamp', correct: true, now: answeredAt);
      final recorded = await misses();

      expect(recorded.containsKey('tamp'), isTrue);
      expect(recorded['tamp']!.isMissed, isFalse);
    },
  );

  test('answers faster than the writes keep every one of them', () async {
    // Each write is a read-modify-write over the whole snapshot. Fired in
    // parallel, the second reads before the first lands and one answer is
    // silently dropped — which is why the log chains them.
    const terms = ['crema', 'tamp', 'arabica', 'robusta', 'espresso'];
    for (var index = 0; index < terms.length; index++) {
      log
          .record(
            termId: terms[index],
            correct: false,
            now: answeredAt.add(Duration(seconds: index)),
          )
          .ignore();
    }
    await log.settled;

    expect((await misses()).keys, unorderedEquals(terms));
  });

  test('a miss and its clear land in the order they were answered', () async {
    log.record(termId: 'crema', correct: false, now: answeredAt).ignore();
    log
        .record(
          termId: 'crema',
          correct: true,
          now: answeredAt.add(const Duration(seconds: 1)),
        )
        .ignore();
    await log.settled;

    expect((await misses())['crema']!.isMissed, isFalse);
  });

  test('nothing else in the snapshot is disturbed', () async {
    // The write is a whole-snapshot replace, so a field it forgets to carry
    // is a field the learner loses.
    await log.record(termId: 'crema', correct: false, now: answeredAt);
    final snapshot = await repo.read();

    expect(snapshot.clearedByReset.activeDays, isEmpty);
    expect(snapshot.updatedAt, answeredAt.millisecondsSinceEpoch);
  });
}
