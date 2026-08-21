import 'package:brew_path/features/learn/domain/module_summary_provider.dart';
import 'package:brew_path/shared/models/coffee_card_model.dart';
import 'package:brew_path/shared/models/lesson_model.dart';
import 'package:brew_path/shared/models/module_model.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/content_fixtures.dart';
import '../../../support/widget_harness.dart';

final ModuleModel _module = testModule();
final CoffeeCardModel _card = testCoffeeCard();
final CoffeeCardModel _fieldGuide = testCoffeeCard(
  id: 'fg1',
  title: 'Beans Field Guide',
  lessonId: null,
  moduleId: 'm1',
);

class _FakeContent extends ContentRepository {
  @override
  Future<List<ModuleModel>> getModules() async => [_module];

  @override
  Future<List<CoffeeCardModel>> getCards() async => [_card, _fieldGuide];

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

  test('joins the lesson cards the learner has actually collected', () async {
    final container = harness();
    await container.read(cardRepositoryProvider).collectCard(_card.id);

    final summary = await container.read(moduleSummaryProvider('m1').future);

    expect(summary.module.id, 'm1');
    expect(summary.earnedCards.map((c) => c.id), [_card.id]);
  });

  test('carries the Field Guide card once it has been collected', () async {
    final container = harness();
    await container.read(cardRepositoryProvider).collectCard(_fieldGuide.id);

    final summary = await container.read(moduleSummaryProvider('m1').future);

    expect(summary.fieldGuide?.id, _fieldGuide.id);
    // It is the module's own reward, not one of the lesson cards.
    expect(summary.earnedCards, isEmpty);
  });

  test('carries no Field Guide card before it is collected', () async {
    final summary = await harness().read(moduleSummaryProvider('m1').future);

    expect(summary.fieldGuide, isNull);
  });
}
