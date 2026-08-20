import 'package:brew_path/features/challenges/domain/challenge_bank.dart';
import 'package:brew_path/shared/models/content/brew_challenge.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/content_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('lookups', () {
    final bank = [
      testChallenge(scope: ChallengeScope.module),
      testChallenge(id: 'bc-m1l1', lessonId: 'm1l1', cardId: 'c1'),
      testChallenge(
        id: 'bc-m2',
        scope: ChallengeScope.module,
        moduleId: 'm2',
        cardId: 'cM2',
      ),
    ];

    test('challengeById finds a record, or nothing', () {
      expect(challengeById(bank, 'bc-m1l1')?.id, 'bc-m1l1');
      expect(challengeById(bank, 'nope'), isNull);
    });

    test('challengeForLesson matches only lesson-scoped records', () {
      expect(challengeForLesson(bank, 'm1l1')?.id, 'bc-m1l1');
      expect(challengeForLesson(bank, 'm1l2'), isNull);
    });

    test('challengeForModule matches only capstones', () {
      // The lesson challenge also carries moduleId m1 — scope is what
      // separates them, so a lookup by module must not return it.
      expect(challengeForModule(bank, 'm1')?.id, 'bc-m1');
      expect(challengeForModule(bank, 'm2')?.id, 'bc-m2');
      expect(challengeForModule(bank, 'm3'), isNull);
    });

    test('challengeForCard finds the challenge stamped on a card', () {
      expect(challengeForCard(bank, 'c1')?.id, 'bc-m1l1');
      expect(challengeForCard(bank, 'nope'), isNull);
    });
  });

  group('effortParts', () {
    test('splits when from how long', () {
      expect(
        effortParts('Next brews · 5 min'),
        (trigger: 'Next brews', duration: '5 min'),
      );
    });

    test('keeps a record with no separator whole, rather than guessing', () {
      expect(
        effortParts('Next brews'),
        (trigger: 'Next brews', duration: null),
      );
    });

    test('reports an empty half as absent', () {
      expect(
        effortParts('Next brews ·'),
        (trigger: 'Next brews', duration: null),
      );
      expect(effortParts('· 5 min'), (trigger: null, duration: '5 min'));
      expect(effortParts(''), (trigger: null, duration: null));
    });
  });

  group('the bundled bank', () {
    test('is twelve challenges: five capstones and seven lessons', () async {
      final bank = await ContentRepository().getBrewChallenges();

      expect(bank.length, 12);
      expect(bank.where((c) => c.scope == ChallengeScope.module).length, 5);
      expect(bank.where((c) => c.scope == ChallengeScope.lesson).length, 7);
    });

    test('gives every lesson challenge an authored lesson id', () async {
      final bank = await ContentRepository().getBrewChallenges();

      for (final challenge in bank) {
        final expectsLesson = challenge.scope == ChallengeScope.lesson;
        expect(
          challenge.lessonId != null,
          expectsLesson,
          reason: '${challenge.id} carries the wrong lesson pointer',
        );
      }
    });

    test('authors reaction counts that are not all the same', () async {
      final bank = await ContentRepository().getBrewChallenges();
      final counts = bank.map((c) => c.reactions.length).toSet();

      // Eleven carry three and one carries two. Asserted as a set so nothing
      // downstream can be built on "always three".
      expect(counts, {2, 3});
    });

    test('gives every record a prompt and at least two reactions', () async {
      final bank = await ContentRepository().getBrewChallenges();

      for (final challenge in bank) {
        expect(challenge.prompt, isNotEmpty, reason: challenge.id);
        expect(challenge.title, isNotEmpty, reason: challenge.id);
        expect(challenge.instruction, isNotEmpty, reason: challenge.id);
        expect(challenge.reactions.length, greaterThanOrEqualTo(2));
      }
    });

    test('points every challenge at content that exists', () async {
      final content = ContentRepository();
      final bank = await content.getBrewChallenges();
      final lessonIds = {for (final l in await content.getLessons()) l.id};
      final moduleIds = {for (final m in await content.getModules()) m.id};
      final cardIds = {for (final c in await content.getCards()) c.id};

      for (final challenge in bank) {
        expect(moduleIds, contains(challenge.moduleId), reason: challenge.id);
        expect(cardIds, contains(challenge.cardId), reason: challenge.id);
        final lessonId = challenge.lessonId;
        if (lessonId != null) {
          expect(lessonIds, contains(lessonId), reason: challenge.id);
        }
      }
    });

    test('has unique ids', () async {
      final bank = await ContentRepository().getBrewChallenges();
      final ids = bank.map((c) => c.id).toList();
      expect(ids.toSet().length, ids.length);
    });
  });
}
