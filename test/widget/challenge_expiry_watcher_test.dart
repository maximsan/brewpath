import 'package:brew_path/features/challenges/domain/challenge_providers.dart';
import 'package:brew_path/features/challenges/presentation/challenge_expiry_watcher.dart';
import 'package:brew_path/shared/repositories/snapshot_repository.dart';
import 'package:brew_path/shared/storage/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Proves the *wiring* of the expiry check: that it runs on a cold start and
/// again on resume, and that it stays silent when nothing has lapsed.
///
/// What counts as lapsed, and what parking writes, is settled in
/// `challenge_parking_test.dart` and `challenge_park_write_test.dart`. This
/// covers only what those cannot — that the widget actually asks, at the two
/// moments the app can act.
///
/// The watcher reads the real clock, so an expired challenge is staged by
/// starting it far in the past rather than by moving time.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late SnapshotRepository snapshots;

  /// Comfortably older than the window, whenever the suite happens to run.
  final longAgo = DateTime(2020);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    AppDatabaseService.instance = db;
    snapshots = SnapshotRepository();
  });

  tearDown(() => db.close());

  Future<String?> activeId() async =>
      (await snapshots.read()).clearedByReset.activeChallenge.value?.id;

  Future<Set<String>> saved() async =>
      (await snapshots.read()).clearedByReset.challengesSaved.value;

  Future<int> stamp() async => (await snapshots.read()).updatedAt;

  Future<void> pumpWatcher(WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ChallengeExpiryWatcher(child: SizedBox()),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// The full background-and-return cycle. `AppLifecycleListener` reports a
  /// resume as a transition, so the app has to leave the foreground first.
  Future<void> backgroundAndResume(WidgetTester tester) async {
    const [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ].forEach(tester.binding.handleAppLifecycleStateChanged);
    await tester.pumpAndSettle();
  }

  testWidgets('a cold start parks a challenge whose window ran out', (
    tester,
  ) async {
    await startChallenge(snapshots, id: 'bc-m1', now: longAgo);

    await pumpWatcher(tester);

    // The common case the watcher exists for: the window ran out while the app
    // was not running at all.
    expect(await activeId(), isNull);
    expect(await saved(), {'bc-m1'});
  });

  testWidgets('a challenge still inside its window is left alone', (
    tester,
  ) async {
    await startChallenge(snapshots, id: 'bc-m1', now: DateTime.now());
    final before = await stamp();

    await pumpWatcher(tester);

    expect(await activeId(), 'bc-m1');
    expect(await saved(), isEmpty);
    // Writing nothing is what lets this run on every open and resume without
    // churning the stamp — and, on a second device, without a write to merge.
    expect(await stamp(), before);
  });

  testWidgets('nothing in play is not a write either', (tester) async {
    final before = await stamp();

    await pumpWatcher(tester);

    expect(await activeId(), isNull);
    expect(await stamp(), before);
  });

  testWidgets('a challenge that lapsed while away is parked on resume', (
    tester,
  ) async {
    await pumpWatcher(tester);

    // Staged after mount, so only the resume path can find it — the cold-start
    // check has already run against an empty snapshot.
    await startChallenge(snapshots, id: 'bc-m2', now: longAgo);
    expect(await activeId(), 'bc-m2');

    await backgroundAndResume(tester);

    expect(await activeId(), isNull);
    expect(await saved(), {'bc-m2'});
  });

  testWidgets('it renders its child untouched', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ChallengeExpiryWatcher(child: SizedBox(key: Key('child'))),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('child')), findsOneWidget);
  });
}
