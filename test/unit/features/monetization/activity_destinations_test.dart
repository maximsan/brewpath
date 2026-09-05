import 'package:brew_path/features/dictionary/domain/flashcard_destination.dart';
import 'package:brew_path/features/dictionary/domain/vocab_destination.dart';
import 'package:brew_path/features/lessons/domain/lesson_destination.dart';
import 'package:brew_path/features/mini_games/domain/mini_game_destination.dart';
import 'package:flutter_test/flutter_test.dart';

/// The register of what spends a free day's allowance.
///
/// §8 caps *full learning/practice activities* and exempts challenges and
/// passive browsing. That line is drawn by one flag on each destination, so
/// this is where it is stated in full — a new destination that quietly sets
/// the flag, or a practice one that quietly drops it, fails here rather than
/// on a learner's screen.
void main() {
  test('the four practice formats each spend one', () {
    expect(lessonRun('m1l1').startsActivity, isTrue);
    // A replay is the same destination as a first run: what a finished run
    // pays is resolved from the progress store, never from the URL (#188).
    expect(vocabGame.startsActivity, isTrue);
    expect(flashcardReview.startsActivity, isTrue);
    // The intro, which is the first screen of a run rather than a page about
    // one — so the cap is asked at the door and never after the briefing.
    expect(miniGameRun('g-match').startsActivity, isTrue);
  });

  test('going back to a tab spends nothing', () {
    expect(learnTab.startsActivity, isFalse);
    expect(pathTab.startsActivity, isFalse);
  });

  test('an ending is not a second activity', () {
    // The completion screen and the module ending are where a finished run
    // lands. Charging for them would take the allowance the run just spent
    // and spend it again on the reward.
    expect(
      lessonCompletion('m1l1', correct: 4, total: 5).startsActivity,
      isFalse,
    );
    expect(moduleSummary('m1').startsActivity, isFalse);
  });

  test('two destinations differing only in what they start are not equal', () {
    // The flag is part of identity, so a destination cannot be copied into a
    // free one by a caller that forgot it.
    const named = RouteDestination(name: 'x');
    const spends = RouteDestination(name: 'x', startsActivity: true);

    expect(named, isNot(spends));
    expect(named.hashCode, isNot(spends.hashCode));
  });
}
