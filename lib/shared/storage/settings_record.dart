// Mutable DTO — fields are self-describing.

import 'package:brew_path/shared/theme/app_theme_mode.dart';

/// Mutable DTO for the singleton settings row. Callers mutate fields in
/// place; the repository maps to/from the Drift companion.
class UserSettingsRecord {
  UserSettingsRecord({
    required this.hapticsEnabled,
    required this.soundEnabled,
    this.id = 1,
    this.onboardingCompleted = false,
    this.themeMode = AppThemeMode.fallback,
    this.tourSeen = false,
    this.tipsSeen = '',
    this.learnerName,
    this.notificationsEnabled = false,
    this.dailyReminderTime,
  });

  int id;
  bool hapticsEnabled;
  bool soundEnabled;
  bool onboardingCompleted;
  AppThemeMode themeMode;
  bool tourSeen;
  String tipsSeen;
  String? learnerName;
  bool notificationsEnabled;
  String? dailyReminderTime;
}
