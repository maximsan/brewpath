import 'package:brew_path/core/constants/points_values.dart';
import 'package:brew_path/features/challenges/domain/challenge_completion.dart';
import 'package:brew_path/shared/models/content/brew_challenge.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/content_fixtures.dart';

void main() {
  group('isFirstCompletion', () {
    test('is true for a challenge never logged', () {
      expect(isFirstCompletion(id: 'bc-m1', completed: const {}), isTrue);
    });

    test('is false once it has been logged', () {
      expect(
        isFirstCompletion(id: 'bc-m1', completed: const {'bc-m1'}),
        isFalse,
      );
    });
  });

  group('challengePayout', () {
    test('pays the flat award the first time', () {
      expect(
        challengePayout(id: 'bc-m1', completed: const {}),
        PointsValues.challengeCompletion,
      );
    });

    test('pays nothing on a replay', () {
      // The challenge stays repeatable precisely because repeating it buys
      // nothing — points measure what was covered, not how often.
      expect(challengePayout(id: 'bc-m1', completed: const {'bc-m1'}), 0);
    });

    test('is unaffected by other challenges being done', () {
      expect(
        challengePayout(id: 'bc-m1', completed: const {'bc-m2', 'bc-m3'}),
        PointsValues.challengeCompletion,
      );
    });
  });

  group('canLogResult', () {
    test('is false until an outcome is picked', () {
      expect(canLogResult(null), isFalse);
    });

    test('is true once one is', () {
      expect(canLogResult('Preferred 1:15'), isTrue);
    });
  });

  group('logReaction', () {
    test('stores the text verbatim, not an index', () {
      // A stored index silently changes meaning when the design rewrites the
      // options — which it has already done once.
      final stored = logReaction(reaction: 'Preferred 1:15', day: 20300);

      expect(stored.reaction, 'Preferred 1:15');
      expect(stored.at, 20300);
    });

    test('keeps a curly apostrophe exactly as authored', () {
      // `bc-m1l1` authors "Bag didn't say" with U+2019.
      const authored = 'Bag didn’t say';
      expect(logReaction(reaction: authored, day: 1).reaction, authored);
    });
  });

  group('challengeTally', () {
    final bank = [
      testChallenge(scope: ChallengeScope.module),
      testChallenge(id: 'bc-m2', scope: ChallengeScope.module, moduleId: 'm2'),
    ];

    test('counts the brewed against the bank', () {
      expect(
        challengeTally(bank: bank, completed: const {'bc-m1'}),
        (brewed: 1, total: 2),
      );
    });

    test('an id the bank no longer carries counts for nothing', () {
      // Otherwise dropping a challenge from the course reads as "3 of 2".
      expect(
        challengeTally(bank: bank, completed: const {'bc-m1', 'bc-retired'}),
        (brewed: 1, total: 2),
      );
    });

    test('an empty bank is nothing out of nothing', () {
      expect(
        challengeTally(bank: const [], completed: const {'bc-m1'}),
        (brewed: 0, total: 0),
      );
    });
  });
}
