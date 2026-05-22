/// Mutable data-transfer object for a lesson-completion row. Decoupled from
/// the Drift table so callers can mutate freely; the repository maps to/from
/// Drift companions.
class ProgressRecord {
  ProgressRecord({
    this.id = 0,
    required this.lessonId,
    required this.isCompleted,
    required this.xpEarned,
    required this.completedAt,
    this.fullXpAwarded = true,
    this.bestScore = 0,
    this.lastPracticeXpDate,
  });

  int id;
  String lessonId;
  bool isCompleted;
  int xpEarned;
  DateTime completedAt;

  /// Whether full lesson XP has already been awarded for this lesson.
  bool fullXpAwarded;

  /// Best first-try accuracy across all runs, as an integer percentage 0–100.
  int bestScore;

  /// Calendar day practice XP was last awarded during review, or null.
  DateTime? lastPracticeXpDate;
}
