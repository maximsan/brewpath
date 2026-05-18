import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// One row per completed lesson. `lessonId` is unique so completion is
/// idempotent via an insert-or-ignore on conflict.
@DataClassName('ProgressRow')
class ProgressRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get lessonId => text().unique()();
  BoolColumn get isCompleted => boolean()();
  IntColumn get xpEarned => integer()();
  DateTimeColumn get completedAt => dateTime()();
}

/// One row per collected card. `cardId` is unique (idempotent collect).
@DataClassName('CardRow')
class CardRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get cardId => text().unique()();
  DateTimeColumn get unlockedAt => dateTime()();
}

/// Singleton settings row — the app always uses the fixed id
/// [SettingsRepository.settingsId].
@DataClassName('SettingsRow')
class UserSettings extends Table {
  IntColumn get id => integer()();
  BoolColumn get hapticsEnabled => boolean()();
  BoolColumn get soundEnabled => boolean()();
  IntColumn get totalXp => integer()();
  IntColumn get streakDays => integer()();
  DateTimeColumn get lastActivityDate => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [ProgressRecords, CardRecords, UserSettings])
class AppDatabase extends _$AppDatabase {
  /// Production opens a platform DB via drift_flutter; tests pass
  /// `NativeDatabase.memory()`.
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'coffee_quest'));

  @override
  int get schemaVersion => 1;
}

/// Static accessor mirroring the former `IsarService.instance` pattern so
/// repositories need no constructor wiring.
class AppDatabaseService {
  AppDatabaseService._();

  static late AppDatabase instance;
}
