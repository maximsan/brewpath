/// The four questions Help answers, three of them re-grounded for this app.
///
/// The design's answers describe a different product: a streak kept by lessons
/// alone, a free tier of a whole module, and a sync that does not exist
/// (#531). Nothing here is written twice — the Foundations answer is built
/// from the pitch the paywall already reads.
library;

import 'package:brew_path/features/monetization/config/paywall_copy.dart';
import 'package:brew_path/features/monetization/domain/free_tier.dart';
import 'package:brew_path/features/monetization/domain/plus_pitch.dart';

/// One question, with the answer that opens under it.
class HelpQuestion {
  /// Creates a [HelpQuestion].
  const HelpQuestion({required this.question, this.answer});

  /// The row's label, which is what a learner scans.
  final String question;

  /// What opens beneath it, or null while its counts are still being read.
  ///
  /// Only the Foundations answer is ever null, and only for as long as the
  /// banks take: the question is drawn either way, so the list never appears
  /// half-built.
  final String? answer;
}

/// The FAQ, in the order the design lists it.
///
/// [pitch], [freeGames] and [foundationsTail] are null until the banks and the
/// store have answered; the other three answers do not wait on them.
List<HelpQuestion> helpFaq({
  PlusPitch? pitch,
  int? freeGames,
  String? foundationsTail,
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
    answer: pitch == null || freeGames == null || foundationsTail == null
        ? null
        : _foundations(pitch, freeGames, foundationsTail),
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

/// What Plus contains, named in the offer's own words.
///
/// The benefit titles, not their counted details: the question is what
/// Foundations includes, and the pitch's numbers belong on the paywall. Read
/// from [paywallBenefitsFor], so a benefit added to the offer arrives here
/// with no edit.
String _foundations(PlusPitch pitch, int freeGames, String tail) {
  final opens = paywallBenefitsFor(
    pitch,
  ).map((benefit) => _openingLower(benefit.title)).toList();

  return 'Foundations opens ${_sentenceList(opens)}. The first '
      '${freeLessonIds.length} lessons stay free, and so do the $freeGames '
      'practice formats they teach. $tail';
}

/// Joins [parts] the way a sentence does — commas, and *and* before the last.
String _sentenceList(List<String> parts) => parts.length < 2
    ? parts.join()
    : '${parts.sublist(0, parts.length - 1).join(', ')} and ${parts.last}';

/// Drops a phrase into mid-sentence without lowercasing a name inside it.
String _openingLower(String phrase) =>
    phrase.isEmpty ? phrase : phrase[0].toLowerCase() + phrase.substring(1);
