/// Mutable DTO for the singleton settings row. Callers (e.g.
/// LessonCompletionService) mutate fields in place; the repository maps
/// to/from the Drift companion.
class UserSettingsRecord {
  UserSettingsRecord({
    required this.hapticsEnabled, required this.soundEnabled, required this.totalXp, required this.streakDays, required this.lastActivityDate, this.id = 1,
    this.onboardingCompleted = false,
    this.onboardingGoal,
    this.onboardingBrewer,
  });

  int id;
  bool hapticsEnabled;
  bool soundEnabled;
  int totalXp;
  int streakDays;
  DateTime? lastActivityDate;
  bool onboardingCompleted;
  String? onboardingGoal;
  String? onboardingBrewer;
}
