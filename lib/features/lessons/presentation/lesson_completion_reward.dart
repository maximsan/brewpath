import 'package:coffee_quest/features/lessons/domain/lesson_completion_service.dart';
import 'package:coffee_quest/shared/models/coffee_card_model.dart';

/// Loaded outcome for the post-lesson screen. Exactly one of [completion] /
/// [reviewResult] is set for first-completion / review runs; both are null for
/// pure practice runs (which write nothing).
class LessonCompletionReward {
  /// Creates a [LessonCompletionReward].
  const LessonCompletionReward({this.completion, this.reviewResult, this.card});

  /// First-completion result (lesson XP, any module bonus), or null.
  final LessonCompletionResult? completion;

  /// Review result (best score, practice XP), or null.
  final LessonReviewResult? reviewResult;

  /// Collectible card unlocked by a first completion, if any.
  final CoffeeCardModel? card;
}
