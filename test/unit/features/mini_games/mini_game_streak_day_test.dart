import 'package:brew_path/core/utils/date_utils.dart';
import 'package:brew_path/features/mini_games/domain/mini_game_completion.dart';
import 'package:brew_path/shared/repositories/snapshot_repository.dart';
import 'package:brew_path/shared/storage/app_database.dart';
import 'package:brew_path/shared/storage/snapshot/daily_activity.dart';
import 'package:brew_path/shared/storage/snapshot/merge_snapshot.dart';
import 'package:brew_path/shared/storage/snapshot/progress_snapshot.dart';
import 'package:brew_path/shared/storage/snapshot/snapshot_scopes.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

String _run(String gameId, String token) =>
    activityEntry(type: ActivityType.miniGame, token: token, subject: gameId);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('the qualifying rule, with no widget or database', () {
    test('two different games mark the day', () {
      expect(
        miniGamesMarkTheDay({_run('g-quiz', 'a'), _run('g-match', 'b')}),
        isTrue,
      );
    });

    test('one run does not', () {
      expect(miniGamesMarkTheDay({_run('g-quiz', 'a')}), isFalse);
    });

    test('the same game twice counts once', () {
      expect(
        miniGamesMarkTheDay({_run('g-quiz', 'a'), _run('g-quiz', 'b')}),
        isFalse,
      );
    });

    test('a third different game changes nothing', () {
      final three = {
        _run('g-quiz', 'a'),
        _run('g-match', 'b'),
        _run('g-flavor', 'c'),
      };

      expect(miniGamesMarkTheDay(three), isTrue);
    });

    test('other activity types are not games', () {
      final day = {
        activityEntry(type: ActivityType.vocab, token: 'a'),
        activityEntry(type: ActivityType.replay, token: 'b', subject: 'm1l1'),
      };

      expect(miniGamesMarkTheDay(day), isFalse);
    });
  });

  // Two devices, one game each, offline: the union is what qualifies the day.
  test('a day qualifies on the union of two devices', () {
    final day = epochDay(DateTime(2026, 8, 19));
    ProgressSnapshot device(String id, String gameId, String token) =>
        ProgressSnapshot(
          deviceId: id,
          clearedByReset: ClearedByReset(
            dailyActivity: {
              day: {_run(gameId, token)},
            },
          ),
        );

    final merged = mergeSnapshot(
      device('phone', 'g-quiz', 'a'),
      device('tablet', 'g-match', 'b'),
    );

    expect(merged.clearedByReset.dailyActivity[day], hasLength(2));
    expect(
      miniGamesMarkTheDay(merged.clearedByReset.dailyActivity[day]!),
      isTrue,
    );
  });

  group('recording a completed run', () {
    late AppDatabase db;
    late SnapshotRepository repo;
    final now = DateTime(2026, 8, 19, 10);
    final day = epochDay(now);

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      AppDatabaseService.instance = db;
      repo = SnapshotRepository();
    });
    tearDown(() async => db.close());

    Future<ClearedByReset> progress() async =>
        (await repo.read()).clearedByReset;

    test(
      'the mark lands on the second different game, not the first',
      () async {
        await recordMiniGameRun(repo, 'g-quiz', now);
        expect((await progress()).activeDays, isEmpty);

        await recordMiniGameRun(repo, 'g-match', now);

        expect((await progress()).activeDays, contains(day));
        expect((await progress()).dailyActivity[day], hasLength(2));
      },
    );

    test('the same game twice records two runs and marks nothing', () async {
      await recordMiniGameRun(repo, 'g-quiz', now);
      await recordMiniGameRun(repo, 'g-quiz', now);

      final after = await progress();
      expect(
        after.dailyActivity[day],
        hasLength(2),
        reason: 'the cap sees two',
      );
      expect(after.activeDays, isEmpty, reason: 'the streak sees one game');
    });

    test('a day marked by mini-games is an ordinary active day', () async {
      await recordMiniGameRun(repo, 'g-quiz', now);
      await recordMiniGameRun(repo, 'g-match', now);

      // Nothing distinguishes it from a day a lesson marked: it is the day.
      expect((await progress()).activeDays, {day});
    });

    test('a reset leaves no trace of play', () async {
      await recordMiniGameRun(repo, 'g-quiz', now);
      await recordMiniGameRun(repo, 'g-match', now);

      await repo.write(
        (await repo.read()).copyWith(clearedByReset: ClearedByReset.empty),
      );

      final after = await progress();
      expect(after.dailyActivity, isEmpty);
      expect(after.activeDays, isEmpty);
    });
  });
}
