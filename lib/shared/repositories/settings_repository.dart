import 'package:brew_path/shared/storage/app_database.dart';
import 'package:brew_path/shared/storage/settings_record.dart';
import 'package:brew_path/shared/theme/app_theme_mode.dart';
import 'package:drift/drift.dart';

/// Reads/writes the singleton user-settings row via Drift.
class SettingsRepository {
  AppDatabase get _db => AppDatabaseService.instance;

  /// Primary-key id of the singleton settings row.
  static const int settingsId = 1;

  /// Returns the singleton settings row, or transient defaults on first
  /// launch (defaults are not persisted until [saveSettings] is called —
  /// matches the prior Isar behavior).
  Future<UserSettingsRecord> getSettings() async {
    final row = await (_db.select(
      _db.userSettings,
    )..where((t) => t.id.equals(settingsId))).getSingleOrNull();
    if (row != null) {
      return UserSettingsRecord(
        id: row.id,
        hapticsEnabled: row.hapticsEnabled,
        soundEnabled: row.soundEnabled,
        totalXp: row.totalXp,
        streakDays: row.streakDays,
        lastActivityDate: row.lastActivityDate,
        onboardingCompleted: row.onboardingCompleted,
        onboardingGoal: row.onboardingGoal,
        onboardingBrewer: row.onboardingBrewer,
        themeMode: AppThemeMode.fromStorage(row.themeMode),
      );
    }
    return UserSettingsRecord(
      hapticsEnabled: true,
      soundEnabled: true,
      totalXp: 0,
      streakDays: 0,
      lastActivityDate: null,
    );
  }

  /// Upserts the singleton settings row.
  Future<void> saveSettings(UserSettingsRecord settings) async {
    await _db
        .into(_db.userSettings)
        .insertOnConflictUpdate(
          UserSettingsCompanion.insert(
            id: const Value(settingsId),
            hapticsEnabled: settings.hapticsEnabled,
            soundEnabled: settings.soundEnabled,
            totalXp: settings.totalXp,
            streakDays: settings.streakDays,
            lastActivityDate: Value(settings.lastActivityDate),
            onboardingCompleted: Value(settings.onboardingCompleted),
            onboardingGoal: Value(settings.onboardingGoal),
            onboardingBrewer: Value(settings.onboardingBrewer),
            themeMode: Value(settings.themeMode.storageValue),
          ),
        );
  }

  /// Resets every user-progress field on the singleton settings row while
  /// preserving the user's haptics and sound preferences. Used by the Profile
  /// "Reset Progress" action.
  Future<void> resetProgress() async {
    final settings = await getSettings();
    // `totalXp` is deliberately absent: the points total is derived from the
    // completions this reset clears, so there is no counter left to zero. The
    // column survives only until the destructive rebuild drops it (#79).
    settings
      ..streakDays = 0
      ..lastActivityDate = null;
    await saveSettings(settings);
  }

  /// Deletes the singleton row, so reads fall back to first-launch defaults.
  ///
  /// **Delete Account only.** This row is the device-local store — appearance,
  /// haptics, sound and the onboarding answers — which a progress reset keeps
  /// deliberately. Delete is the one wipe it does not survive.
  Future<void> deleteAll() async {
    await _db.delete(_db.userSettings).go();
  }
}
