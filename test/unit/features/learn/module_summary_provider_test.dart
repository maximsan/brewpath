import 'package:brew_path/features/learn/domain/module_summary_provider.dart';
import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:brew_path/shared/models/coffee_card_model.dart';
import 'package:brew_path/shared/models/lesson_model.dart';
import 'package:brew_path/shared/models/module_model.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/content_fixtures.dart';
import '../../../support/widget_harness.dart';

final _module = testModule(lessonIds: const ['m1l1', 'm1l2']);
final _card = testCoffeeCard();

class _FakeContent extends ContentRepository {
  @override
  Future<List<ModuleModel>> getModules() async => [_module];

  @override
  Future<List<CoffeeCardModel>> getCards() async => [_card];

  @override
  Future<List<LessonModel>> getLessons() async => [
    testLesson(),
    testLesson(id: 'm1l2', title: 'm1l2'),
  ];
}

void main() {
  setUp(useInMemoryDatabase);

  test('joins earned cards and sums module XP plus the bonus', () async {
    final container = ProviderContainer(
      overrides: [
        contentRepositoryProvider.overrideWith((ref) => _FakeContent()),
      ],
    );
    addTearDown(container.dispose);

    // Complete both lessons (40 + 30 XP) and collect the m1l1 card.
    final progress = container.read(progressRepositoryProvider);
    await progress.saveCompletion(
      lessonId: 'm1l1',
      xpEarned: 40,
      mastery: const MasteryResult(correct: 5, total: 5),
    );
    await progress.saveCompletion(
      lessonId: 'm1l2',
      xpEarned: 30,
      mastery: const MasteryResult(correct: 5, total: 5),
    );
    await container.read(cardRepositoryProvider).collectCard('c1');

    final summary = await container.read(
      moduleSummaryProvider('m1').future,
    );

    expect(summary.module.id, 'm1');
    expect(summary.earnedCards.map((c) => c.id), ['c1']);
    // 40 + 30 lesson XP + 25 module bonus.
    expect(summary.totalXp, 95);
  });
}
