import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/features/learn/domain/keep_sharp.dart';
import 'package:brew_path/features/learn/domain/learn_providers.dart';
import 'package:brew_path/features/progress/domain/progress_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'keep_sharp_providers.g.dart';

/// The mini-games rule promises "two different games", so the type is only
/// recommended when at least two are playable — a card must never ask for
/// something its own material makes impossible.
const int _minPlayableGameTypes = 2;

/// The day's Keep Sharp recommendation for the Today card's caught-up state:
/// the picked practice type plus the named-route destination its CTA opens.
/// Not persisted — a read-side view value, like `ModuleWithProgress`.
class KeepSharpRecommendation {
  /// Creates a [KeepSharpRecommendation].
  const KeepSharpRecommendation({
    required this.type,
    required this.routeName,
    required this.pathParams,
  });

  /// The recommended practice type.
  final PracticeType type;

  /// The go_router name of the type's surface.
  final String routeName;

  /// Path parameters the surface needs — a concrete entry point; the
  /// recommendation itself stays type-level.
  final Map<String, String> pathParams;
}

/// Derives the day's recommendation: eligibility (a registered surface with
/// material) feeds the pure rotation, and the CTA's concrete entry point is
/// the same day's [keepSharpDailyChoice] so it, too, is stable all day and
/// stores nothing. Null when no registered type has material.
@riverpod
Future<KeepSharpRecommendation?> keepSharpRecommendation(Ref ref) async {
  final day = keepSharpDayNumber(DateTime.now());
  final counts = await ref.watch(gameTypePracticeCountsProvider.future);
  final completed = await ref.watch(completedLessonsProvider.future);

  final playableGameTypes = [
    for (final (key, _) in gameTypeLabels)
      if ((counts[key] ?? 0) > 0) key,
  ];
  final completedIds = [for (final record in completed) record.lessonId];

  final eligible = {
    if (playableGameTypes.length >= _minPlayableGameTypes)
      PracticeType.miniGames,
    if (completedIds.isNotEmpty) PracticeType.lessonReplay,
  }.intersection(builtPracticeSurfaces);

  final pick = keepSharpPick(dayNumber: day, eligible: eligible);
  return switch (pick) {
    null => null,
    PracticeType.miniGames => KeepSharpRecommendation(
      type: pick,
      routeName: AppRoutes.practiceGameType.name,
      pathParams: {'gameType': keepSharpDailyChoice(day, playableGameTypes)},
    ),
    PracticeType.lessonReplay => KeepSharpRecommendation(
      type: pick,
      routeName: AppRoutes.practiceLesson.name,
      pathParams: {'lessonId': keepSharpDailyChoice(day, completedIds)},
    ),
    // Gated out by builtPracticeSurfaces until their surfaces register.
    PracticeType.vocabGame || PracticeType.flashcards => null,
  };
}
