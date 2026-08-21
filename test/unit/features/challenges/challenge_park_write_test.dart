import 'dart:convert';

import 'package:brew_path/features/challenges/domain/challenge_lifecycle.dart';
import 'package:brew_path/features/challenges/domain/challenge_providers.dart';
import 'package:brew_path/shared/repositories/snapshot_repository.dart';
import 'package:brew_path/shared/storage/app_database.dart';
import 'package:brew_path/shared/storage/snapshot/snapshot_scopes.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Park, don't drop — against a real database.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late SnapshotRepository snapshots;

  final at = DateTime(2026, 8, 20, 12);
  final pastWindow = at.add(challengeWindow).add(const Duration(minutes: 1));

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    AppDatabaseService.instance = db;
    snapshots = SnapshotRepository();
  });

  tearDown(() => db.close());

  Future<ClearedByReset> progress() async =>
      (await snapshots.read()).clearedByReset;

  Future<Set<String>> saved() async => (await progress()).challengesSaved.value;
  Future<String?> activeId() async =>
      (await progress()).activeChallenge.value?.id;

  group('save for later', () {
    test('parks the challenge and clears Today', () async {
      await startChallenge(snapshots, id: 'bc-m1', now: at);
      await saveActiveChallengeForLater(snapshots, id: 'bc-m1', now: at);

      expect(await saved(), {'bc-m1'});
      expect(await activeId(), isNull);
    });
  });

  group('displacement', () {
    test('starting another challenge parks the first', () async {
      await startChallenge(snapshots, id: 'bc-m1', now: at);
      await startChallenge(snapshots, id: 'bc-m2', now: at);

      expect(await saved(), {'bc-m1'});
      expect(await activeId(), 'bc-m2');
    });

    test('a finished challenge is not re-queued when displaced', () async {
      await startChallenge(snapshots, id: 'bc-m1', now: at);
      await logChallenge(
        snapshots,
        id: 'bc-m1',
        reaction: 'Preferred 1:15',
        now: at,
      );
      await startChallenge(snapshots, id: 'bc-m1', now: at); // replay
      await startChallenge(snapshots, id: 'bc-m2', now: at);

      expect(await saved(), isEmpty);
    });

    test('starting a queued challenge takes it out of the queue', () async {
      await startChallenge(snapshots, id: 'bc-m1', now: at);
      await saveActiveChallengeForLater(snapshots, id: 'bc-m1', now: at);
      await startChallenge(snapshots, id: 'bc-m1', now: at);

      // It cannot be both waiting and in play.
      expect(await saved(), isEmpty);
      expect(await activeId(), 'bc-m1');
    });
  });

  test('logging takes the challenge out of the queue too', () async {
    await startChallenge(snapshots, id: 'bc-m1', now: at);
    await saveActiveChallengeForLater(snapshots, id: 'bc-m1', now: at);
    await startChallenge(snapshots, id: 'bc-m1', now: at);
    await logChallenge(
      snapshots,
      id: 'bc-m1',
      reaction: 'Hard to tell',
      now: at,
    );

    expect(await saved(), isEmpty);
  });

  group('expiry', () {
    test('parks the lapsed challenge and clears the stale pair', () async {
      await startChallenge(snapshots, id: 'bc-m1', now: at);

      final parked = await parkExpiredChallenge(snapshots, now: pastWindow);

      expect(parked, isTrue);
      expect(await saved(), {'bc-m1'});
      // The defect this fixes: the pair used to persist forever, so an
      // expired challenge would sync between devices as the active one.
      expect(await activeId(), isNull);
    });

    test('writes nothing while the window is live', () async {
      await startChallenge(snapshots, id: 'bc-m1', now: at);
      final before = jsonEncode((await snapshots.read()).toJson());

      final parked = await parkExpiredChallenge(snapshots, now: at);

      expect(parked, isFalse);
      expect(jsonEncode((await snapshots.read()).toJson()), before);
    });

    test('writes nothing when nothing is in play', () async {
      final before = jsonEncode((await snapshots.read()).toJson());

      expect(await parkExpiredChallenge(snapshots, now: pastWindow), isFalse);
      expect(jsonEncode((await snapshots.read()).toJson()), before);
    });

    test('running it again leaves the stored payload byte-identical', () async {
      await startChallenge(snapshots, id: 'bc-m1', now: at);
      await parkExpiredChallenge(snapshots, now: pastWindow);
      final afterFirst = jsonEncode((await snapshots.read()).toJson());

      final second = await parkExpiredChallenge(
        snapshots,
        now: pastWindow.add(const Duration(days: 5)),
      );

      // The strongest form of "changes nothing": not merely equal state, but
      // the same bytes — so no stamp moved either.
      expect(second, isFalse);
      expect(jsonEncode((await snapshots.read()).toJson()), afterFirst);
    });

    test('a lapsed challenge already logged is cleared, not queued', () async {
      await startChallenge(snapshots, id: 'bc-m1', now: at);
      await logChallenge(
        snapshots,
        id: 'bc-m1',
        reaction: 'Preferred 1:15',
        now: at,
      );
      await startChallenge(snapshots, id: 'bc-m1', now: at); // replay

      await parkExpiredChallenge(snapshots, now: pastWindow);

      expect(await saved(), isEmpty);
      expect(await activeId(), isNull);
    });
  });

  test('unsave takes a challenge out of the queue', () async {
    await startChallenge(snapshots, id: 'bc-m1', now: at);
    await saveActiveChallengeForLater(snapshots, id: 'bc-m1', now: at);

    await unsaveChallenge(snapshots, id: 'bc-m1', now: at);

    expect(await saved(), isEmpty);
  });
}
