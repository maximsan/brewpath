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
        onboardingCompleted: row.onboardingCompleted,
        onboardingGoal: row.onboardingGoal,
        onboardingBrewer: row.onboardingBrewer,
        themeMode: AppThemeMode.fromStorage(row.themeMode),
        tourSeen: row.tourSeen,
        learnerName: row.learnerName,
      );
    }
    return UserSettingsRecord(
      hapticsEnabled: true,
      soundEnabled: true,
      totalXp: 0,
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
            onboardingCompleted: Value(settings.onboardingCompleted),
            onboardingGoal: Value(settings.onboardingGoal),
            onboardingBrewer: Value(settings.onboardingBrewer),
            themeMode: Value(settings.themeMode.storageValue),
            tourSeen: Value(settings.tourSeen),
            learnerName: Value(settings.learnerName),
          ),
        );
  }

  /// Deletes the singleton row, so reads fall back to first-launch defaults.
  ///
  /// **Delete Account only.** This row is the device-local store — appearance,
  /// haptics, sound, the onboarding answers and the Tour's `tourSeen` bit —
  /// which a progress reset keeps deliberately. Delete is the one wipe it does
  /// not survive, and it takes `onboardingCompleted` and `tourSeen` together,
  /// which is the fate-sharing rule those two are owed.
  Future<void> deleteAll() async {
    await _db.delete(_db.userSettings).go();
  }
}
