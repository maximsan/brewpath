import 'package:isar/isar.dart';

part 'settings_record.g.dart';

@collection
class UserSettingsRecord {
  /// Fixed ID 0 makes this a singleton row — only one settings object ever exists.
  Id id = 0;

  late bool hapticsEnabled;
  late bool soundEnabled;
  late int totalXp;
  late int streakDays;
  late DateTime? lastActivityDate;
}
