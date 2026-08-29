import 'package:brew_path/features/lessons/domain/lesson_finish_result.dart';
import 'package:brew_path/shared/models/coffee_card_model.dart';
import 'package:brew_path/shared/models/lesson_model.dart';

/// Everything the post-lesson screen needs, loaded once: what the run did, the
/// lesson it did it to, the card a first completion unlocked, and what is
/// queued behind it.
///
/// Assembled in one pass so the screen renders from a single snapshot. Reading
/// any of it a second time during the celebration would let the screen disagree
/// with itself — the next lesson in particular, which the completion just
/// changed.
class LessonCompletionReward {
  /// Creates a [LessonCompletionReward].
  const LessonCompletionReward({
    required this.result,
    required this.lesson,
    this.card,
    this.nextLessonId,
  });

  /// What the run actually recorded — first completion or replay, decided by
  /// the service from the progress store rather than by this screen.
  final LessonFinishResult result;

  /// The lesson just finished. Its title is the screen's headline.
  final LessonModel lesson;

  /// Collectible card unlocked by a first completion, if any.
  final CoffeeCardModel? card;

  /// The next lesson the course has queued, or null when it has none left —
  /// which is what parts the design's `Next lesson` CTA from `Back to Path`.
  final String? nextLessonId;
}
