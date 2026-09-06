import 'package:brew_path/features/learn/domain/module_summary_provider.dart';
import 'package:brew_path/shared/models/coffee_card_model.dart';
import 'package:brew_path/shared/models/lesson_model.dart';
import 'package:brew_path/shared/models/module_model.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/content_fixtures.dart';
import '../../../support/progress_seed.dart';
import '../../../support/widget_harness.dart';

final ModuleModel _module = testModule();
final CoffeeCardModel _card = testCoffeeCard();
// The title is the one the bundled bank actually ships. A card's name is
// authored content and stays as authored; Module Reward is the category,
// not the title (CONTEXT.md).
final CoffeeCardModel _moduleReward = testCoffeeCard(
  id: 'cM1',
  title: 'Beans Field Guide',
  lessonId: null,
  moduleId: 'm1',
);

class _FakeContent extends ContentRepository {
  @override
  Future<List<ModuleModel>> getModules() async => [_module];

  @override
  Future<List<CoffeeCardModel>> getCards() async => [_card, _moduleReward];

  @override
  Future<List<LessonModel>> getLessons() async => [
    testLesson(),
    testLesson(id: 'm1l2', title: 'm1l2'),
  ];
}

void main() {
  setUp(useInMemoryDatabase);

  /// A container over the fake course, with the real repositories behind it.
  ProviderContainer harness() {
    final container = ProviderContainer(
      overrides: [
        contentRepositoryProvider.overrideWith((ref) => _FakeContent()),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('names the module that closed', () async {
    final summary = await harness().read(moduleSummaryProvider('m1').future);

    expect(summary.module.id, 'm1');
  });

  test(
    'the ending has nowhere further to go at the end of the course',
    () async {
      // One module in the fixture, so nothing follows it — the action reads
      // *Back to Path* and goes there.
      final summary = await harness().read(moduleSummaryProvider('m1').future);

      expect(summary.nextLessonId, isNull);
      expect(summary.hasNextModule, isFalse);
    },
  );

  test('carries the Module Reward card once it has been collected', () async {
    final container = harness();
    await seedCollectible(
      container.read(snapshotRepositoryProvider),
      _moduleReward.id,
    );

    final summary = await container.read(moduleSummaryProvider('m1').future);

    expect(summary.moduleReward?.id, _moduleReward.id);
  });

  test('carries no Module Reward card before it is collected', () async {
    final summary = await harness().read(moduleSummaryProvider('m1').future);

    expect(summary.moduleReward, isNull);
  });
}
