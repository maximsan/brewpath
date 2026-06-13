/// Remote Config key names. Reads go through `RemoteConfigService` only.
abstract class RemoteConfigKeys {
  /// Minimum supported app version; below it forces an update.
  static const String forceUpdateMinVersion = 'force_update_min_version';

  /// Target number of lessons per day.
  static const String dailyLessonGoal = 'daily_lesson_goal';

  /// Whether collectible-card animations are enabled.
  static const String enableCardAnimations = 'enable_card_animations';
}
