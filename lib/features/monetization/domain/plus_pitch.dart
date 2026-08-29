/// What Plus contains, counted from the banks rather than written down.
///
/// **Nothing here is a literal, on purpose.** This repo has shipped a stale
/// number twice — the points ceiling stated as 370 went stale at 380 one
/// design pass later — and both times the number had been written into prose.
/// A paywall is the highest-consequence copy in the app, so every quantity in
/// the pitch is derived from the content banks joined to the free-tier rule,
/// and authoring a lesson or a game cannot make it lie.
///
/// Pure, so a wrong count fails in a unit test rather than on a learner's
/// screen.
library;

import 'package:brew_path/features/mini_games/domain/mini_game_tier.dart';
import 'package:brew_path/features/monetization/domain/free_tier.dart';
import 'package:brew_path/features/saved/domain/saved_cap.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';
import 'package:brew_path/shared/models/content/mini_game_format.dart';
import 'package:brew_path/shared/models/lesson_model.dart';

/// The quantities the pitch names, all of them counted.
class PlusPitch {
  /// Creates a [PlusPitch].
  const PlusPitch({
    required this.remainingLessons,
    required this.lockedGames,
    required this.referenceTerms,
    required this.savedFreeCap,
  });

  /// Lessons the free tier does not carry — what "the rest of the course" is.
  final int remainingLessons;

  /// Games a free learner cannot open.
  final int lockedGames;

  /// Terms no lesson teaches, which only the Dictionary carries.
  final int referenceTerms;

  /// How many things a free shelf holds before it refuses.
  final int savedFreeCap;
}

/// Counts [PlusPitch] from the shipped banks and the free-tier rule.
///
/// Every argument is a whole bank rather than a number, so a caller cannot
/// pass a count that disagrees with the content.
PlusPitch derivePlusPitch({
  required List<LessonModel> lessons,
  required List<MiniGameFormat> games,
  required List<DictionaryTerm> terms,
}) => PlusPitch(
  remainingLessons: lessons.where((lesson) => !isLessonFree(lesson.id)).length,
  lockedGames: games.length - freeMiniGameIds(games).length,
  // A term with no teaching lesson is one the course never introduces, so the
  // Dictionary is the only place it exists — which is what makes it worth
  // naming in the pitch.
  referenceTerms: terms.where((term) => term.lessonId == null).length,
  savedFreeCap: savedFreeMax,
);
