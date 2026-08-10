import 'package:brew_path/features/learn/domain/module_summary_provider.dart';
import 'package:brew_path/shared/models/coffee_card_model.dart';
import 'package:brew_path/shared/models/lesson_model.dart';
import 'package:brew_path/shared/models/lesson_step_model.dart';
import 'package:brew_path/shared/models/module_model.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/widget_harness.dart';

const _step = LessonStepModel.multipleChoice(
  question: 'Q',
  options: ['a', 'b'],
  correctIndex: 0,
  explanation: 'E',
);

LessonModel _lesson(String id, {String? cardId}) => LessonModel(
  id: id,
  moduleId: 'module_beans',
  title: id,
  summary: '',
  xpReward: 50,
  cardId: cardId,
  steps: const [_step],
);

const _module = ModuleModel(
  id: 'module_beans',
  title: 'Beans',
  description: '',
  iconName: 'beans',
  lessonIds: ['l1', 'l2'],
);

const _card = CoffeeCardModel(
  id: 'c1',
  title: 'First Card',
  description: '',
  moduleTag: 'Beans',
  iconName: 'beans',
  lessonId: 'l1',
);

class _FakeContent extends ContentRepository {
  @override
  Future<List<ModuleModel>> getModules() async => const [_module];

  @override
  Future<List<CoffeeCardModel>> getCards() async => const [_card];

  @override
  Future<List<LessonModel>> getLessons() async => [
    _lesson('l1'),
    _lesson('l2'),
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

    // Complete both lessons (40 + 30 XP) and collect the l1 card.
    final progress = container.read(progressRepositoryProvider);
    await progress.saveCompletion(lessonId: 'l1', xpEarned: 40, score: 100);
    await progress.saveCompletion(lessonId: 'l2', xpEarned: 30, score: 100);
    await container.read(cardRepositoryProvider).collectCard('c1');

    final summary = await container.read(
      moduleSummaryProvider('module_beans').future,
    );

    expect(summary.module.id, 'module_beans');
    expect(summary.earnedCards.map((c) => c.id), ['c1']);
    // 40 + 30 lesson XP + 25 module bonus.
    expect(summary.totalXp, 95);
  });
}
