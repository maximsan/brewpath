import 'package:brew_path/features/monetization/config/paywall_copy.dart';
import 'package:brew_path/features/monetization/domain/free_tier.dart';
import 'package:brew_path/features/monetization/domain/plus_pitch.dart';
import 'package:brew_path/features/profile/domain/help_faq.dart';
import 'package:brew_path/features/tour/domain/app_guide_copy.dart';
import 'package:flutter_test/flutter_test.dart';

const _pitch = PlusPitch(
  remainingLessons: 29,
  lockedGames: 4,
  premiumFormats: 5,
  firstPaidModule: 2,
  lastPaidModule: 5,
  referenceTerms: 8,
  savedFreeCap: 5,
);

const _tail = 'Buy it once and nothing renews.';

List<HelpQuestion> _faq({
  PlusPitch pitch = _pitch,
  int freeGames = 6,
  String tail = _tail,
}) => helpFaq(pitch: pitch, freeGames: freeGames, foundationsTail: tail);

String _answerContaining(List<HelpQuestion> faq, String needle) => faq
    .firstWhere(
      (entry) => entry.question.contains(needle),
      orElse: () => throw StateError('no question mentioning "$needle"'),
    )
    .answer!;

void main() {
  group('the four questions the design asks', () {
    test('are all four, in the design order', () {
      expect(_faq().map((entry) => entry.question), [
        'How does my streak work?',
        'How does my tree grow?',
        'What does Foundations include?',
        'Can I learn offline?',
      ]);
    });

    test('every question has an answer, so no row is a dead end', () {
      for (final entry in _faq()) {
        expect(entry.answer, isNotEmpty, reason: entry.question);
      }
    });

    test('only the counted answer waits, and only for its counts', () {
      // The three static answers are drawn before the banks reply; a list
      // that waited on all four would hide questions that never needed it.
      final pending = helpFaq();

      expect(pending, hasLength(4));
      expect(
        pending.where((entry) => entry.answer == null).single.question,
        'What does Foundations include?',
      );
    });
  });

  group('the streak answer agrees with the App Guide', () {
    test('names a finished activity, not a lesson a day', () {
      final answer = _answerContaining(_faq(), 'streak');

      expect(answer, contains('activity'));
      expect(
        answer,
        isNot(contains('lesson a day')),
        reason: "the design's understatement is the thing #531 re-grounds",
      );
    });

    test('names the same three activities the App Guide does', () {
      final answer = _answerContaining(_faq(), 'streak');

      for (final activity in ['lesson', 'replay', 'practice']) {
        expect(answer, contains(activity), reason: activity);
      }
    });

    test('carries the freeze rule the App Guide states', () {
      expect(_answerContaining(_faq(), 'streak'), contains('freeze'));
    });

    test('the App Guide it must not disagree with still says so', () {
      // If the guide is reworded, this fails and the FAQ is rewritten with it
      // rather than drifting apart in silence.
      final streak = AppGuideCopy.sections.firstWhere(
        (section) => section.title == 'Streak',
      );

      expect(streak.body, contains('One finished activity a day'));
      expect(streak.body, contains('freeze'));
    });
  });

  group('the Foundations answer is derived, never typed', () {
    test('counts the free lessons from the free-tier list', () {
      expect(
        _answerContaining(_faq(), 'Foundations'),
        contains('${freeLessonIds.length}'),
      );
    });

    test('counts the free formats from the free-games rule', () {
      expect(
        _answerContaining(_faq(freeGames: 7), 'Foundations'),
        contains('7'),
      );
    });

    test('ends on the purchase model, whatever the arm sells', () {
      expect(
        _answerContaining(_faq(tail: 'Cancel anytime.'), 'Foundations'),
        endsWith('Cancel anytime.'),
      );
    });

    test("names what Plus contains in the paywall's own words", () {
      // Falsifies "derived": the answer must be built from the offer's own
      // benefit list, so a benefit added there arrives here with no edit.
      final answer = _answerContaining(_faq(), 'Foundations');

      for (final benefit in paywallBenefitsFor(_pitch)) {
        expect(
          answer.toLowerCase(),
          contains(benefit.title.toLowerCase()),
          reason: benefit.title,
        );
      }
    });

    test('reads as one sentence, not a list of counts', () {
      // The design's answer flows; the counted details belong on the paywall,
      // which is the surface that pitches them.
      final answer = _answerContaining(_faq(), 'Foundations');

      expect(answer, isNot(contains(';')));
      expect(answer, isNot(contains('(')));
      expect(answer, contains('and the Studio.'));
    });

    test('the free counts move with the banks they are read from', () {
      expect(
        _answerContaining(_faq(freeGames: 3), 'Foundations'),
        contains('the 3 practice formats'),
      );
      expect(
        _answerContaining(_faq(freeGames: 9), 'Foundations'),
        contains('the 9 practice formats'),
      );
    });
  });

  group('the offline answer promises only what the app does', () {
    test('promises no sync, because nothing syncs', () {
      final answer = _answerContaining(_faq(), 'offline');

      expect(answer, isNot(contains('sync')));
    });

    test('says the course and progress are kept on this phone', () {
      final answer = _answerContaining(_faq(), 'offline');

      expect(answer, contains('phone'));
    });
  });

  test('the tree answer keeps the design, which is true as written', () {
    final answer = _answerContaining(_faq(), 'tree');

    expect(answer, contains('core'));
    expect(answer, contains('ten stages'));
    expect(answer, contains('reset'));
  });

  test('no answer promises a reply time', () {
    // #531: one developer cannot promise a reply time, and nothing replaces
    // the design's line.
    for (final entry in _faq()) {
      expect(
        entry.answer,
        isNot(contains('within a day')),
        reason: entry.question,
      );
      expect(
        entry.answer,
        isNot(contains('usually faster')),
        reason: entry.question,
      );
    }
  });
}
