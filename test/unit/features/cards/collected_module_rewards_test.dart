// The completion moment's Module Reward stat, read against the real bank: a
// derivation that miscounted the five would still pass a hand-built fixture.
import 'package:brew_path/features/cards/domain/cards_providers.dart';
import 'package:brew_path/features/cards/domain/module_rewards.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
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

  test('the bank holds five Module Rewards among its thirty-seven', () async {
    final cards = await ContentRepository().getCards();

    expect(cards, hasLength(37));
    expect(moduleRewardCount(cards), 5);
  });

  test('a learner who owns nothing owns no Module Reward', () async {
    expect(await harness().read(collectedModuleRewardsProvider.future), 0);
  });

  test('lesson cards raise the count for none of the five', () async {
    await seedCollectible(snapshots, 'c1');
    await seedCollectible(snapshots, 'c2');

    expect(await harness().read(collectedModuleRewardsProvider.future), 0);
  });

  test('a module card counts, and only for itself', () async {
    await seedCollectible(snapshots, 'c1');
    await seedCollectible(snapshots, 'cM1');

    expect(await harness().read(collectedModuleRewardsProvider.future), 1);
  });

  test('a finished learner holding every card counts all five', () async {
    for (final card in await ContentRepository().getCards()) {
      await seedCollectible(snapshots, card.id);
    }

    expect(await harness().read(collectedModuleRewardsProvider.future), 5);
  });
}
