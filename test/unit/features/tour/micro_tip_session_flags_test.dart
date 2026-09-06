import 'package:brew_path/features/progress/domain/progress_providers.dart';
import 'package:brew_path/features/progress/domain/streak_status.dart';
import 'package:brew_path/features/saved/domain/saved_providers.dart';
import 'package:brew_path/features/tour/domain/micro_tip_providers.dart';
import 'package:brew_path/shared/repositories/snapshot_repository.dart';
import 'package:brew_path/shared/storage/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/progress_seed.dart';

/// The two flags that remember an event rather than a state.
///
/// Both watch a set the app already keeps and arm on a *rise* in it, which is
/// the whole difference between "you have just saved something" and "you have
/// things saved". A learner who opens the app with a full shelf is owed no
/// explanation of what saving does.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    AppDatabaseService.instance = db;
    container = ProviderContainer();
    addTearDown(container.dispose);
    addTearDown(db.close);
  });

  group('a save this session', () {
    test('is not armed by a shelf the learner arrived with', () async {
      await toggleSaved(
        SnapshotRepository(),
        key: 'term:crema',
        now: DateTime(2026, 9, 5),
        isPlus: true,
        visible: 0,
      );

      // The first resolve is what the learner already had, not something they
      // just did.
      expect(await container.read(savedKeysProvider.future), hasLength(1));
      expect(container.read(saveMadeThisSessionProvider), isFalse);
    });

    test('is armed when the shelf grows', () async {
      await container.read(savedKeysProvider.future);
      expect(container.read(saveMadeThisSessionProvider), isFalse);

      await toggleSaved(
        SnapshotRepository(),
        key: 'term:crema',
        now: DateTime(2026, 9, 5),
        isPlus: true,
        visible: 0,
      );
      container.invalidate(savedKeysProvider);
      await container.read(savedKeysProvider.future);

      expect(container.read(saveMadeThisSessionProvider), isTrue);
    });

    test('is not armed when something is taken off the shelf', () async {
      await toggleSaved(
        SnapshotRepository(),
        key: 'term:crema',
        now: DateTime(2026, 9, 5),
        isPlus: true,
        visible: 0,
      );
      await container.read(savedKeysProvider.future);
      expect(container.read(saveMadeThisSessionProvider), isFalse);

      await toggleSaved(
        SnapshotRepository(),
        key: 'term:crema',
        now: DateTime(2026, 9, 5),
        isPlus: true,
        visible: 1,
      );
      container.invalidate(savedKeysProvider);
      await container.read(savedKeysProvider.future);

      expect(container.read(saveMadeThisSessionProvider), isFalse);
    });
  });

  group('a freeze earned this session', () {
    StreakStatus statusWith({required bool freezeHeld}) => StreakStatus(
      streak: 7,
      freezeHeld: freezeHeld,
      daysToNextFreeze: freezeHeld ? null : 3,
      freezesSpent: freezeHeld ? 0 : 1,
      frozenDays: freezeHeld ? const {} : const {12},
    );

    test('is armed by the earn, and outlives spending it', () async {
      // The streak is fed by hand here because what is under test is the
      // flag's memory of a rise, not how a day set comes to earn a freeze.
      var held = false;
      final container = ProviderContainer(
        overrides: [
          streakStatusProvider.overrideWith(
            (ref) async => statusWith(freezeHeld: held),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(streakStatusProvider.future);
      expect(container.read(freezeEarnedThisSessionProvider), isFalse);

      held = true;
      container.invalidate(streakStatusProvider);
      await container.read(streakStatusProvider.future);
      expect(container.read(freezeEarnedThisSessionProvider), isTrue);

      // Spent on a missed day, which is what makes this flag worth keeping:
      // the learner was shown a safety net and now holds none.
      held = false;
      container.invalidate(streakStatusProvider);
      await container.read(streakStatusProvider.future);
      expect(container.read(freezeEarnedThisSessionProvider), isTrue);
    });

    test('is not armed by a freeze the learner arrived holding', () async {
      final container = ProviderContainer(
        overrides: [
          streakStatusProvider.overrideWith(
            (ref) async => statusWith(freezeHeld: true),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(streakStatusProvider.future);

      expect(container.read(freezeEarnedThisSessionProvider), isFalse);
    });
  });

  group('a lesson finished this session', () {
    test('is armed when the finished set grows', () async {
      await container.read(completedLessonIdsProvider.future);
      expect(container.read(lessonFinishedThisSessionProvider), isFalse);

      await seedCompletedLesson(SnapshotRepository(), 'm1l1');
      container.invalidate(completedLessonsProvider);
      await container.read(completedLessonIdsProvider.future);

      expect(container.read(lessonFinishedThisSessionProvider), isTrue);
    });

    test('is not armed by lessons the learner arrived with', () async {
      await seedCompletedLesson(SnapshotRepository(), 'm1l1');

      expect(await container.read(completedLessonIdsProvider.future), {'m1l1'});
      expect(container.read(lessonFinishedThisSessionProvider), isFalse);
    });
  });
}
