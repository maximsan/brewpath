import 'package:brew_path/features/profile/domain/reset_summary.dart';
import 'package:brew_path/features/progress/domain/progress_write.dart';
import 'package:brew_path/features/saved/domain/saved_key.dart';
import 'package:brew_path/features/saved/domain/saved_providers.dart';
import 'package:brew_path/shared/models/coffee_card_model.dart';
import 'package:brew_path/shared/models/content/brew_challenge.dart';
import 'package:brew_path/shared/models/lesson_model.dart';
import 'package:brew_path/shared/models/module_model.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:brew_path/shared/storage/snapshot/snapshot_scopes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/content_fixtures.dart';
import '../../../support/progress_seed.dart';
import '../../../support/widget_harness.dart';

final ModuleModel _module = testModule();
final CoffeeCardModel _card = testCoffeeCard();
final CoffeeCardModel _reward = testCoffeeCard(
  id: 'cM1',
  lessonId: null,
  moduleId: 'm1',
);

class _FakeContent extends ContentRepository {
  @override
  Future<List<ModuleModel>> getModules() async => [_module];

  @override
  Future<List<CoffeeCardModel>> getCards() async => [_card, _reward];

  @override
  Future<List<LessonModel>> getLessons() async => [
    testLesson(),
    testLesson(id: 'm1l2', title: 'm1l2'),
  ];

  @override
  Future<List<BrewChallenge>> getBrewChallenges() async => [
    testChallenge(id: 'bc-m1l1', lessonId: 'm1l1'),
    testChallenge(id: 'bc-m2', scope: ChallengeScope.module, moduleId: 'm2'),
  ];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(useInMemoryDatabase);

  ProviderContainer harness() {
    final container = ProviderContainer(
      overrides: [
        contentRepositoryProvider.overrideWith((ref) => _FakeContent()),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  /// Each line as `label — value`, held open while it resolves: a bare `read`
  /// of the future closes its subscription and the chain disposes mid-load.
  Future<List<String>> summaryOf(ProviderContainer container) async {
    addTearDown(container.listen(resetSummaryProvider, (_, _) {}).close);
    return [
      for (final line in await container.read(resetSummaryProvider.future))
        '${line.label} — ${line.value}',
    ];
  }

  test('the reset scope is exactly the fields the sheet accounts for', () {
    // The pin the sheet rests on: a new progress field lands here first, and
    // whoever adds it rules whether it earns a line of its own or falls under
    // the closing line. Adding one silently is what this fails on.
    expect(ClearedByReset.empty.toJson().keys, [
      'completedLessons',
      'bestResults',
      'activeDays',
      'acks',
      'ownedCollectibles',
      'completedModules',
      'treeStage',
      'challengesCompleted',
      'learnedTerms',
      'termAnswers',
      'challengeReactions',
      'dailyActivity',
      'challengesSaved',
      'activeChallenge',
      'favourites',
    ]);
  });

  test('an untouched learner is offered seven zeroes, in the design order', () {
    expect(
      summaryOf(harness()),
      completion([
        'Daily streak — 0 days',
        'Points earned — 0 pts',
        'Lessons completed — 0',
        'Cards collected — 0 of 2',
        'Coffee challenges — 0 of 2',
        'Saved items — 0',
        'Your coffee tree — Back to Seed',
      ]),
    );
  });

  test("the lines carry this learner's own figures", () async {
    final container = harness();
    final snapshots = container.read(snapshotRepositoryProvider);
    await seedCompletedLesson(snapshots, 'm1l1');
    await seedCollectible(snapshots, _card.id);
    await updateProgress(
      snapshots,
      (progress) => progress.withChallengeLogged(
        'bc-m1l1',
        reaction: 'Preferred 1:15',
        day: 0,
      ),
      now: DateTime.now(),
    );
    await toggleSaved(
      snapshots,
      key: formatSavedKey(SavedKind.lesson, 'm1l1'),
      now: DateTime.now(),
      isPlus: true,
      visible: 0,
    );

    expect(await summaryOf(container), [
      'Daily streak — 1 day',
      'Points earned — 15 pts',
      'Lessons completed — 1',
      'Cards collected — 1 of 2',
      'Coffee challenges — 1 of 2',
      'Saved items — 1',
      'Your coffee tree — Back to Seed',
    ]);
  });
}
