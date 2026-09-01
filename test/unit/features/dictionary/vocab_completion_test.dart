// What a finished vocab round leaves behind: one activity entry, and the day
// marked. The rule itself lives in `dayQualifies` — this asserts that the
// drill goes through the shared writer and inherits it rather than restating
// it (#33, #65).
import 'package:brew_path/core/utils/date_utils.dart';
import 'package:brew_path/features/dictionary/domain/vocab_completion.dart';
import 'package:brew_path/shared/repositories/snapshot_repository.dart';
import 'package:brew_path/shared/storage/app_database.dart';
import 'package:brew_path/shared/storage/snapshot/daily_activity.dart';
import 'package:brew_path/shared/storage/snapshot/snapshot_scopes.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late SnapshotRepository repo;
  final now = DateTime(2026, 9, 1, 10);
  final day = epochDay(now);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    AppDatabaseService.instance = db;
    repo = SnapshotRepository();
  });
  tearDown(() async => db.close());

  Future<ClearedByReset> progress() async => (await repo.read()).clearedByReset;

  test('one finished round marks the day on its own', () async {
    // Unlike mini-games, which need two different games: the drill's own
    // qualifying rule, asked once by the shared writer.
    await recordVocabRound(repo, now);

    expect((await progress()).activeDays, contains(day));
  });

  test('it writes one entry, of the vocab type', () async {
    await recordVocabRound(repo, now);

    final entries = (await progress()).dailyActivity[day]!;

    expect(entries, hasLength(1));
    expect(parseActivityEntry(entries.single).type, ActivityType.vocab);
  });

  test('two rounds are two entries, so the allowance sees two', () async {
    // A record keyed on type would collapse them, and the free daily cap has
    // to count completions rather than kinds.
    await recordVocabRound(repo, now);
    await recordVocabRound(repo, now);

    expect((await progress()).dailyActivity[day], hasLength(2));
  });

  test('nothing is recorded until a round is finished', () async {
    // The screen calls this only on reaching the score; an abandoned drill
    // never gets there, so the store is untouched.
    expect((await progress()).dailyActivity, isEmpty);
    expect((await progress()).activeDays, isEmpty);
  });

  test('a reset leaves no trace of the drill', () async {
    await recordVocabRound(repo, now);

    await repo.write(
      (await repo.read()).copyWith(clearedByReset: ClearedByReset.empty),
    );

    expect((await progress()).dailyActivity, isEmpty);
    expect((await progress()).activeDays, isEmpty);
  });
}
