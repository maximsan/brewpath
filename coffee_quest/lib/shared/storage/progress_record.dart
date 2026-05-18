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
  });

  int id;
  String lessonId;
  bool isCompleted;
  int xpEarned;
  DateTime completedAt;
}
