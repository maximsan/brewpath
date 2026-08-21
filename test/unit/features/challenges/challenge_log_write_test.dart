import 'package:brew_path/core/constants/points_values.dart';
import 'package:brew_path/features/challenges/domain/challenge_providers.dart';
import 'package:brew_path/shared/repositories/snapshot_repository.dart';
import 'package:brew_path/shared/storage/app_database.dart';
import 'package:brew_path/shared/storage/snapshot/snapshot_scopes.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Logging a brew, against a real database.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late SnapshotRepository snapshots;

  // Pinned, so a run started before midnight and asserted after it cannot fail.
  final at = DateTime(2026, 8, 20, 12);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    AppDatabaseService.instance = db;
    snapshots = SnapshotRepository();
  });

  tearDown(() => db.close());

  Future<ClearedByReset> progress() async =>
      (await snapshots.read()).clearedByReset;

  Future<int> log({
    String id = 'bc-m1',
    String reaction = 'Preferred 1:15',
    DateTime? now,
  }) => logChallenge(
    snapshots,
    id: id,
    reaction: reaction,
    now: now ?? at,
  );

  /// What the logged challenges are worth, counted the way the derived total
  /// counts them — off the completed set, which is the only record kept.
  Future<int> bankedPoints() async =>
      (await progress()).challengesCompleted.length *
      PointsValues.challengeCompletion;

  test('a first log records the brew, its outcome, and pays', () async {
    final paid = await log();
    final after = await progress();

    expect(paid, PointsValues.challengeCompletion);
    expect(after.challengesCompleted, contains('bc-m1'));
    expect(after.challengeReactions['bc-m1']?.reaction, 'Preferred 1:15');
    expect(await bankedPoints(), PointsValues.challengeCompletion);
  });

  test('logging clears the challenge from Today', () async {
    await startChallenge(snapshots, id: 'bc-m1', now: at);
    expect((await progress()).activeChallenge.value?.id, 'bc-m1');

    await log();

    // Recorded as done while still sitting on Today is a state nothing else
    // knows how to read, so the two move together.
    expect((await progress()).activeChallenge.value, isNull);
  });

  test('a replay pays nothing and replaces the outcome', () async {
    await log();
    final paid = await log(
      reaction: 'Hard to tell',
      now: at.add(
        const Duration(days: 1),
      ),
    );

    expect(paid, 0);
    expect(await bankedPoints(), PointsValues.challengeCompletion);
    expect(
      (await progress()).challengeReactions['bc-m1']?.reaction,
      'Hard to tell',
    );
  });

  test('two different challenges each pay once', () async {
    await log();
    await log(id: 'bc-m2', reaction: 'Called it');

    expect(await bankedPoints(), PointsValues.challengeCompletion * 2);
    expect(
      (await progress()).challengesCompleted,
      containsAll(<String>['bc-m1', 'bc-m2']),
    );
  });

  group('records nothing it is not meant to', () {
    // §4: a Coffee Challenge is not an activity. Its completion can be
    // reported without the app being able to tell, so it protects no streak
    // and consumes no daily allowance. The exclusion is structural — nothing
    // else stops a later refactor reaching for `recordActivity`, which is
    // exactly what these assertions are for.
    test('no streak day, no daily activity', () async {
      await log();
      final after = await progress();

      expect(after.activeDays, isEmpty);
      expect(after.dailyActivity, isEmpty);
    });

    test('no tree growth and no mastery', () async {
      await log();
      final after = await progress();

      expect(after.treeStage, 0);
      expect(after.bestResults, isEmpty);
      expect(after.completedLessons, isEmpty);
    });

    test('no collectible', () async {
      await log();
      expect((await progress()).ownedCollectibles, isEmpty);
    });
  });
}
