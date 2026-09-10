/// The four questions Help answers, three of them re-grounded for this app.
///
/// The design's answers describe a different product: a streak kept by lessons
/// alone, a free tier of a whole module, and a sync that does not exist
/// (#531). Every quantity is counted from the banks, so authoring content
/// cannot make an answer lie.
library;

import 'package:brew_path/features/monetization/domain/free_tier.dart';
import 'package:brew_path/features/monetization/domain/plus_pitch.dart';

/// One question and the answer that opens under it.
class HelpQuestion {
  /// Creates a [HelpQuestion].
  const HelpQuestion({required this.question, required this.answer});

  /// The row's label, which is what a learner scans.
  final String question;

  /// What opens inline beneath it. Never empty — no row is a dead end.
  final String answer;
}

/// The FAQ, in the order the design lists it.
///
/// [freeGames] is the count of formats a free learner may open, and
/// [foundationsTail] the selling model's own closing sentence — both passed in
/// so this stays pure and never learns which pricing arm is live.
List<HelpQuestion> helpFaq({
  required PlusPitch pitch,
  required int freeGames,
  required String foundationsTail,
}) => [
  const HelpQuestion(
    question: 'How does my streak work?',
    // Says what `AppGuideCopy`'s Streak section says, under the same #338
    // ruling; a test fails if the two drift apart.
    answer:
        'One finished activity a day keeps it alive — a lesson, a replay, or '
        'practice. Every 7 days in a row earns a streak freeze; you hold one '
        'at a time, and it covers a missed day automatically, so the day '
        'shows as covered in your week.',
  ),
  const HelpQuestion(
    question: 'How does my tree grow?',
    answer:
        'Your tree tracks the core course only — it moves up a stage as you '
        'complete core lessons, through ten stages from bare seed to full '
        'harvest. Points from practice and reviews don’t grow it, and it '
        'never shrinks unless you reset your progress.',
  ),
  HelpQuestion(
    question: 'What does Foundations include?',
    answer: _foundations(pitch, freeGames, foundationsTail),
  ),
  const HelpQuestion(
    question: 'Can I learn offline?',
    // The design promises "Progress syncs the next time you're online".
    // Nothing syncs, so nothing is promised about another device.
    answer:
        'Yes — the whole course is on your phone, and so is your progress. '
        'Lessons, practice and the Dictionary all work with no connection, '
        'and everything you finish is kept on this phone.',
  ),
];

String _foundations(PlusPitch pitch, int freeGames, String tail) =>
    'Foundations opens the rest of the course: ${pitch.remainingLessons} more '
    'lessons, ${pitch.lockedGames} more mini-games, the '
    '${pitch.referenceTerms} Dictionary terms no lesson teaches, Saved past '
    'its free shelf of ${pitch.savedFreeCap}, and the Studio. The first '
    '${freeLessonIds.length} lessons stay free, and so do the $freeGames '
    'practice formats they teach. $tail';
