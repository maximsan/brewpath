// Mutable DTO — fields are self-describing.
// ignore_for_file: public_member_api_docs

import 'package:brew_path/features/progress/domain/mastery.dart';

/// Mutable data-transfer object for a lesson-completion row. Decoupled from
/// the Drift table so callers can mutate freely; the repository maps to/from
/// Drift companions.
class ProgressRecord {
  ProgressRecord({
    required this.lessonId,
    required this.isCompleted,
    required this.xpEarned,
    required this.completedAt,
    this.id = 0,
    this.fullXpAwarded = true,
    MasteryResult? mastery,
    this.lastPracticeXpDate,
  }) : mastery = mastery ?? MasteryResult.unscored;

  int id;
  String lessonId;
  bool isCompleted;
  int xpEarned;
  DateTime completedAt;

  /// Whether full lesson XP has already been awarded for this lesson.
  bool fullXpAwarded;

  /// The lesson's best graded result, as the `{correct, total}` pair.
  /// [MasteryResult.unscored] for a lesson finished without a stored score.
  MasteryResult mastery;

  /// Calendar day practice XP was last awarded during review, or null.
  DateTime? lastPracticeXpDate;
}
