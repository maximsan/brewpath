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
        themeMode: AppThemeMode.fromStorage(row.themeMode),
        tourSeen: row.tourSeen,
        tipsSeen: row.tipsSeen,
        learnerName: row.learnerName,
        notificationsEnabled: row.notificationsEnabled,
        dailyReminderTime: row.dailyReminderTime,
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
            // `onboardingGoal` and `onboardingBrewer` are deliberately
            // absent: ADR-0010 retired both questions, and a `Value` left off
            // an upsert keeps whatever the column already holds rather than
            // writing null over an old install's answer.
            themeMode: Value(settings.themeMode.storageValue),
            tourSeen: Value(settings.tourSeen),
            tipsSeen: Value(settings.tipsSeen),
            learnerName: Value(settings.learnerName),
            notificationsEnabled: Value(settings.notificationsEnabled),
            dailyReminderTime: Value(settings.dailyReminderTime),
          ),
        );
  }

  /// Deletes the singleton row, so reads fall back to first-launch defaults.
  ///
  /// **Delete Account only.** This row is the device-local store — appearance,
  /// haptics, sound, the onboarding gate, the Tour's `tourSeen` bit and the
  /// micro-tips' seen list — which a progress reset keeps deliberately. Delete
  /// is the one wipe it does not survive, and it takes `onboardingCompleted`,
  /// `tourSeen` and `tipsSeen` together, which is the fate-sharing rule those
  /// three are owed.
  Future<void> deleteAll() async {
    await _db.delete(_db.userSettings).go();
  }
}
