/// What Plus contains, counted from the banks rather than written down.
///
/// **Nothing here is a literal, on purpose**: this repo has shipped a stale
/// number twice, both times written into prose. Every quantity derives from
/// the banks joined to the free-tier rule, and is pure so a wrong count fails
/// in a unit test rather than on a learner's screen.
library;

import 'dart:math' as math;

import 'package:brew_path/features/mini_games/domain/mini_game_tier.dart';
import 'package:brew_path/features/monetization/domain/free_tier.dart';
import 'package:brew_path/features/saved/domain/saved_cap.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';
import 'package:brew_path/shared/models/content/mini_game_format.dart';
import 'package:brew_path/shared/models/lesson_model.dart';
import 'package:brew_path/shared/models/module_model.dart';

/// The quantities the pitch names, all of them counted.
class PlusPitch {
  /// Creates a [PlusPitch].
  const PlusPitch({
    required this.remainingLessons,
    required this.lockedGames,
    required this.premiumFormats,
    required this.firstPaidModule,
    required this.lastPaidModule,
    required this.referenceTerms,
    required this.savedFreeCap,
  });

  /// Lessons the free tier does not carry — what "the rest of the course" is.
  final int remainingLessons;

  /// Games a free learner cannot open.
  final int lockedGames;

  /// Kinds of game with no free entry at all — the formats only Plus has.
  final int premiumFormats;

  /// The first module number with no free lesson, or 0 when every module has
  /// one — what the "Modules 2–5" line counts from.
  final int firstPaidModule;

  /// The last module number with no free lesson, or 0 when every module has
  /// one.
  final int lastPaidModule;

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
  required List<ModuleModel> modules,
  required List<LessonModel> lessons,
  required List<MiniGameFormat> games,
  required List<DictionaryTerm> terms,
}) {
  final freeGames = freeMiniGameIds(games).toSet();
  final kinds = {for (final game in games) game.kind};
  final freeKinds = {
    for (final game in games)
      if (freeGames.contains(game.id)) game.kind,
  };
  final paidModules = [
    for (final module in modules)
      if (!module.lessons.any((lesson) => isLessonFree(lesson.id))) module.n,
  ];

  return PlusPitch(
    remainingLessons: lessons
        .where((lesson) => !isLessonFree(lesson.id))
        .length,
    lockedGames: games.length - freeGames.length,
    premiumFormats: kinds.difference(freeKinds).length,
    firstPaidModule: paidModules.isEmpty ? 0 : paidModules.reduce(math.min),
    lastPaidModule: paidModules.isEmpty ? 0 : paidModules.reduce(math.max),
    // A term with no teaching lesson is one the course never introduces, so
    // the Dictionary is the only place it exists — which is what makes it
    // worth naming in the pitch.
    referenceTerms: terms.where((term) => term.lessonId == null).length,
    savedFreeCap: savedFreeMax,
  );
}
