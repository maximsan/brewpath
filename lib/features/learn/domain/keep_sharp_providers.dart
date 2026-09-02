import 'package:brew_path/core/utils/date_utils.dart';
import 'package:brew_path/features/dictionary/domain/vocab_providers.dart';
import 'package:brew_path/features/learn/domain/keep_sharp.dart';
import 'package:brew_path/features/learn/domain/keep_sharp_completion.dart';
import 'package:brew_path/features/lessons/domain/lesson_destination.dart';
import 'package:brew_path/features/mini_games/domain/mini_game_providers.dart';
import 'package:brew_path/features/mini_games/domain/mini_game_run.dart';
import 'package:brew_path/features/progress/domain/progress_providers.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:brew_path/shared/storage/snapshot/daily_activity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'keep_sharp_providers.g.dart';

/// The day's Keep Sharp recommendation for the Today card's caught-up state:
/// the picked practice type plus the named-route destination its CTA opens.
/// Not persisted — a read-side view value, like `ModuleWithProgress`.
class KeepSharpRecommendation {
  /// Creates a [KeepSharpRecommendation].
  const KeepSharpRecommendation({
    required this.type,
    required this.destination,
  });

  /// The recommended practice type.
  final PracticeType type;

  /// The one screen the CTA opens — a concrete entry point; the recommendation
  /// itself stays type-level.
  final RouteDestination destination;
}

/// Derives the day's recommendation: the learner's material feeds the pure
/// rotation, which returns the type and the one screen its CTA opens. Null
/// when no registered type has material.
///
/// The reads are the material the rule is asked of: which formats are playable,
/// which the learner already played today, and which lessons they have
/// finished. Every decision made from them lives in [keepSharpResolutionFor].
@riverpod
Future<KeepSharpRecommendation?> keepSharpRecommendation(Ref ref) async {
  final day = keepSharpDayNumber(DateTime.now());
  // Watches before awaits: a mid-flight rebuild must not reach a watch
  // across an async gap on a disposed ref.
  final formatsFuture = ref.watch(miniGameFormatsProvider.future);
  final completedFuture = ref.watch(completedLessonsProvider.future);
  final poolsFuture = ref.watch(vocabPoolsProvider.future);
  final snapshotFuture = ref.watch(snapshotRepositoryProvider).read();
  final formats = await formatsFuture;
  final completed = await completedFuture;
  final pools = await poolsFuture;
  final snapshot = await snapshotFuture;

  final resolution = keepSharpResolutionFor(
    dayNumber: day,
    material: (
      playableFormatIds: [
        for (final format in formats)
          if (playableMiniGameIds.contains(format.id)) format.id,
      ],
      formatsPlayedToday: distinctMiniGameIds(
        snapshot.clearedByReset.dailyActivity[day] ?? const {},
      ),
      completedLessonIds: [for (final record in completed) record.lessonId],
      drillableTermCount: pools.accessible.length,
      // The same pools value: the deck a flashcard review deals is the saved
      // half of it, so the two drills cannot disagree about the learner's own
      // material.
      flashcardDeckSize: pools.saved.length,
    ),
  );

  return resolution == null
      ? null
      : KeepSharpRecommendation(
          type: resolution.type,
          destination: resolution.destination,
        );
}

/// Whether today's recommendation has met its own completion rule — derived
/// per-day from what the activity layer already records, stored nowhere.
///
/// Mini-game runs record themselves on the day's activity (#126), so the
/// two-different-games rule reads the distinct game ids among today's entries
/// — the same record the streak's qualifying day derives from.
@riverpod
Future<bool> keepSharpAcknowledgedToday(Ref ref) async {
  final recommendationFuture = ref.watch(
    keepSharpRecommendationProvider.future,
  );
  final snapshotFuture = ref.watch(snapshotRepositoryProvider).read();
  final snapshot = await snapshotFuture;
  final recommendation = await recommendationFuture;
  if (recommendation == null) return false;

  final today = epochDay(DateTime.now());
  // One read, feeding both rules: replays and mini-game runs are entries on
  // the same day record, so neither needs a source of its own.
  final entriesToday = snapshot.clearedByReset.dailyActivity[today] ?? const {};

  return keepSharpRuleMet(
    recommendation.type,
    distinctGamesToday: distinctMiniGameIds(entriesToday).length,
    replayedToday: anyReplayToday(entriesToday),
    vocabRoundToday: anyVocabRoundToday(entriesToday),
    reviewedFlashcardsToday: anyFlashcardReviewToday(entriesToday),
  );
}
