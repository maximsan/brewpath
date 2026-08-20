import 'package:brew_path/features/lessons/domain/lesson_finish_result.dart';
import 'package:brew_path/shared/models/coffee_card_model.dart';

/// Loaded outcome for the post-lesson screen: what the run did, plus the card
/// a first completion unlocked.
class LessonCompletionReward {
  /// Creates a [LessonCompletionReward].
  const LessonCompletionReward({required this.result, this.card});

  /// What the run actually recorded — first completion or replay, decided by
  /// the service from the progress store rather than by this screen.
  final LessonFinishResult result;

  /// Collectible card unlocked by a first completion, if any.
  final CoffeeCardModel? card;
}
