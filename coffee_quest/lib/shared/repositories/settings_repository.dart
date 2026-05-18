import 'package:drift/drift.dart';
import 'package:coffee_quest/shared/storage/app_database.dart';
import 'package:coffee_quest/shared/storage/settings_record.dart';

class SettingsRepository {
  AppDatabase get _db => AppDatabaseService.instance;

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
      );
    }
    return UserSettingsRecord(
      id: settingsId,
      hapticsEnabled: true,
      soundEnabled: true,
      totalXp: 0,
      streakDays: 0,
      lastActivityDate: null,
    );
  }

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
          ),
        );
  }

  Future<void> addXp(int xp) async {
    final settings = await getSettings();
    settings.totalXp += xp;
    await saveSettings(settings);
  }
}
