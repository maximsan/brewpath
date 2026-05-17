import 'package:isar/isar.dart';
import 'package:coffee_quest/shared/storage/isar_service.dart';
import 'package:coffee_quest/shared/storage/settings_record.dart';

class SettingsRepository {
  Isar get _isar => IsarService.instance;

  static const int _settingsId = 0;

  /// Returns the singleton settings row, seeding defaults on first launch.
  Future<UserSettingsRecord> getSettings() async {
    final record = await _isar.userSettingsRecords.get(_settingsId);
    if (record != null) return record;
    return UserSettingsRecord()
      ..id = _settingsId
      ..hapticsEnabled = true
      ..soundEnabled = true
      ..totalXp = 0
      ..streakDays = 0
      ..lastActivityDate = null;
  }

  Future<void> saveSettings(UserSettingsRecord settings) async {
    await _isar.writeTxn(() async {
      await _isar.userSettingsRecords.put(settings);
    });
  }

  Future<void> addXp(int xp) async {
    final settings = await getSettings();
    settings.totalXp += xp;
    await saveSettings(settings);
  }
}
