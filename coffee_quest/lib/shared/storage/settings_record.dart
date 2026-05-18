/// Mutable DTO for the singleton settings row. Callers (e.g.
/// LessonCompletionService) mutate fields in place; the repository maps
/// to/from the Drift companion.
class UserSettingsRecord {
  UserSettingsRecord({
    this.id = 1,
    required this.hapticsEnabled,
    required this.soundEnabled,
    required this.totalXp,
    required this.streakDays,
    required this.lastActivityDate,
  });

  int id;
  bool hapticsEnabled;
  bool soundEnabled;
  int totalXp;
  int streakDays;
  DateTime? lastActivityDate;
}
