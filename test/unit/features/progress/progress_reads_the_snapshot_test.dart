// Progress is read from the snapshot (#115), and the old normalised tables it
// replaced are gone (#116). Each case writes only the snapshot and asks the
// providers the screens read, so a reader that went looking anywhere else
// fails here rather than in a screen nobody opened.
import 'package:brew_path/features/cards/domain/cards_providers.dart';
import 'package:brew_path/features/learn/domain/learn_providers.dart';
import 'package:brew_path/features/path/domain/path_providers.dart';
import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:brew_path/features/progress/domain/progress_providers.dart';
import 'package:brew_path/shared/repositories/snapshot_repository.dart';
import 'package:brew_path/shared/storage/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/progress_seed.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late SnapshotRepository snapshots;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    AppDatabaseService.instance = db;
    snapshots = SnapshotRepository();
  });
  tearDown(() async => db.close());

  ProviderContainer harness() {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    return container;
  }

  test('a finished lesson is finished off the snapshot alone', () async {
    await seedCompletedLesson(
      snapshots,
      'm1l1',
      mastery: const MasteryResult(correct: 4, total: 5),
    );
    final container = harness();

    expect(await container.read(completedLessonIdsProvider.future), {'m1l1'});
    expect(
      (await container.read(coreLessonProgressProvider.future)).completed,
      1,
    );
    // The flat ten m1l1 authors, summed off the course rather than stored.
    expect(await container.read(totalPointsProvider.future), 10);
  });

  test('the result it was scored on comes off the snapshot too', () async {
    // #79's ruling, rehomed on #115: the stored pair moved onto the snapshot,
    // so #116 could drop the old table without losing what a learner scored.
    await seedCompletedLesson(
      snapshots,
      'm1l1',
      mastery: const MasteryResult(correct: 4, total: 5),
    );

    final modules = await harness().read(modulesWithProgressProvider.future);
    expect(modules.first.completedCount, 1);

    final path = await harness().read(pathModulesProvider.future);
    final row = path
        .expand((module) => module.lessons)
        .firstWhere((entry) => entry.lesson.id == 'm1l1');
    expect(row.mastery, const MasteryResult(correct: 4, total: 5));
    expect(row.isCompleted, isTrue);
  });

  test('a collected card is held off the snapshot alone', () async {
    await seedCollectible(snapshots, 'c1');
    final container = harness();

    final cards = await container.read(cardsWithCollectionProvider.future);
    expect(
      cards.firstWhere((entry) => entry.card.id == 'c1').isCollected,
      isTrue,
    );
    expect(cards.where((entry) => entry.isCollected), hasLength(1));
  });

  test('Today moves past what the snapshot says is finished', () async {
    await seedCompletedLesson(snapshots, 'm1l1');

    expect((await harness().read(todayLessonProvider.future))?.id, 'm1l2');
  });
}
