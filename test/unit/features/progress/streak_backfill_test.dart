// The move onto the day set, seen from an install that predates it.
//
// The unit that matters is `streakDaySet`; this pins the wiring, because the
// failure it guards against is silent — a learner opens the update and their
// streak reads zero, with nothing throwing anywhere.
import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:brew_path/features/progress/domain/progress_providers.dart';
import 'package:brew_path/shared/repositories/progress_repository.dart';
import 'package:brew_path/shared/repositories/snapshot_repository.dart';
import 'package:brew_path/shared/storage/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late ProgressRepository progress;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    AppDatabaseService.instance = db;
    progress = ProgressRepository();
  });
  tearDown(() async => db.close());

  /// A completion record dated [at] — the shape an install carries from before
  /// anything wrote a day. `saveCompletion` stamps now, so it is backdated.
  Future<void> completedOn(String lessonId, DateTime at) async {
    await progress.saveCompletion(
      lessonId: lessonId,
      xpEarned: 10,
      mastery: const MasteryResult(correct: 1, total: 1),
    );
    final record = (await progress.getByLessonId(lessonId))!;
    record.completedAt = at;
    await progress.saveProgress(record);
  }

  /// Midday, [back] whole calendar days ago.
  ///
  /// Built by field arithmetic from a fixed hour, never by subtracting a
  /// `Duration` from `DateTime.now()`. Both alternatives are time-dependent:
  /// subtracting hours crosses midnight when the suite runs just after it, and
  /// subtracting whole days lands on the wrong day across a DST boundary. The
  /// provider reads the real clock for *today*, so the anchor has to be real —
  /// only the time of day is pinned.
  DateTime daysAgo(int back) {
    final today = DateTime.now();
    return DateTime(today.year, today.month, today.day - back, 12);
  }

  Future<int> streak() async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    return container.read(streakProvider.future);
  }

  test('a learner with no history at all reads zero', () async {
    expect(await streak(), 0);
  });

  test('completions recorded before the day set existed still count', () async {
    for (var back = 0; back < 3; back++) {
      await completedOn('l$back', daysAgo(back));
    }

    // Nothing has ever written the day set on this install.
    expect(
      (await SnapshotRepository().read()).clearedByReset.activeDays,
      isEmpty,
    );
    expect(await streak(), 3, reason: 'the streak survives the move');
  });

  test('two completions on one day are still one day', () async {
    final today = daysAgo(0);
    await completedOn('l1', today);
    await completedOn('l2', DateTime(today.year, today.month, today.day, 8));

    expect(await streak(), 1);
  });

  test('a gap in the backfilled history still breaks the streak', () async {
    await completedOn('l1', daysAgo(0));
    await completedOn('l2', daysAgo(3));

    expect(await streak(), 1, reason: 'the fold reads it like any other set');
  });

  test('a reset clears the completions, so nothing is resurrected', () async {
    await completedOn('l1', daysAgo(0));
    expect(await streak(), 1);

    // What `AccountWipe` does to the legacy tables.
    await progress.deleteAll();

    expect(await streak(), 0);
  });

  test('the backfilled day earns toward a freeze like any other', () async {
    for (var back = 0; back < 7; back++) {
      await completedOn('l$back', daysAgo(back));
    }

    final container = ProviderContainer();
    addTearDown(container.dispose);
    final status = await container.read(streakStatusProvider.future);

    expect(status.streak, 7);
    expect(status.freezeHeld, isTrue);
  });
}
