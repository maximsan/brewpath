// Progress is read from the snapshot, not from the old tables (#115).
//
// The claim these pin is the one the ticket makes: *emptying the old tables
// changes nothing on screen*. Each case writes the snapshot, empties the
// tables, and asks the providers the screens actually read — so a reader left
// behind on `ProgressRepository` or `CardRepository` fails here rather than in
// a screen nobody thought to open.
import 'package:brew_path/features/cards/domain/cards_providers.dart';
import 'package:brew_path/features/learn/domain/learn_providers.dart';
import 'package:brew_path/features/path/domain/path_providers.dart';
import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:brew_path/features/progress/domain/progress_providers.dart';
import 'package:brew_path/shared/repositories/card_repository.dart';
import 'package:brew_path/shared/repositories/progress_repository.dart';
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

  /// Empties the tables #116 drops, so anything still reading them reads
  /// nothing.
  Future<void> emptyTheOldTables() async {
    await ProgressRepository().deleteAll();
    await CardRepository().deleteAll();
  }

  test('a finished lesson is finished with the old tables empty', () async {
    await seedCompletedLesson(
      snapshots,
      'm1l1',
      mastery: const MasteryResult(correct: 4, total: 5),
    );
    await emptyTheOldTables();
    final container = harness();

    expect(await container.read(completedLessonIdsProvider.future), {'m1l1'});
    expect(
      (await container.read(coreLessonProgressProvider.future)).completed,
      1,
    );
    // The flat ten m1l1 authors, summed off the course rather than stored.
    expect(await container.read(totalPointsProvider.future), 10);
  });

  test('the result it was scored on survives the same emptying', () async {
    // #79's ruling, rehomed on #115: the stored pair moves onto the snapshot,
    // so #116 can drop the old table without losing what a learner scored.
    await seedCompletedLesson(
      snapshots,
      'm1l1',
      mastery: const MasteryResult(correct: 4, total: 5),
    );
    await emptyTheOldTables();

    final modules = await harness().read(modulesWithProgressProvider.future);
    expect(modules.first.completedCount, 1);

    final path = await harness().read(pathModulesProvider.future);
    final row = path
        .expand((module) => module.lessons)
        .firstWhere((entry) => entry.lesson.id == 'm1l1');
    expect(row.mastery, const MasteryResult(correct: 4, total: 5));
    expect(row.isCompleted, isTrue);
  });

  test('a collected card is held with the old tables empty', () async {
    await seedCollectible(snapshots, 'c1');
    await emptyTheOldTables();
    final container = harness();

    expect(await container.read(collectedCardsProvider.future), ['c1']);
    final cards = await container.read(cardsWithCollectionProvider.future);
    expect(
      cards.firstWhere((entry) => entry.card.id == 'c1').isCollected,
      isTrue,
    );
  });

  test('Today moves past what the snapshot says is finished', () async {
    await seedCompletedLesson(snapshots, 'm1l1');
    await emptyTheOldTables();

    expect((await harness().read(todayLessonProvider.future))?.id, 'm1l2');
  });
}
