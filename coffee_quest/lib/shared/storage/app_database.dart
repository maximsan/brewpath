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

  /// Whether full lesson XP has already been awarded. Defaults to `true` so
  /// rows migrated from schema v1 (which were created only on first
  /// completion) keep their already-earned status.
  BoolColumn get fullXpAwarded => boolean().withDefault(const Constant(true))();

  /// Best first-try accuracy across all runs, as an integer percentage 0–100.
  IntColumn get bestScore => integer().withDefault(const Constant(0))();

  /// Calendar day practice XP was last awarded for this lesson during review.
  DateTimeColumn get lastPracticeXpDate => dateTime().nullable()();
}

/// One row per module whose module-completion XP has been awarded. `moduleId`
/// is unique so the bonus is granted at most once per module.
@DataClassName('ModuleProgressRow')
class ModuleProgressRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get moduleId => text().unique()();
  BoolColumn get moduleXpAwarded => boolean()();
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

@DriftDatabase(
  tables: [ProgressRecords, CardRecords, UserSettings, ModuleProgressRecords],
)
class AppDatabase extends _$AppDatabase {
  /// Production opens a platform DB via drift_flutter; tests pass
  /// `NativeDatabase.memory()`.
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'coffee_quest'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      // v1 → v2: review/mastery columns + the module-XP ledger table.
      if (from < 2) {
        await m.addColumn(progressRecords, progressRecords.fullXpAwarded);
        await m.addColumn(progressRecords, progressRecords.bestScore);
        await m.addColumn(progressRecords, progressRecords.lastPracticeXpDate);
        await m.createTable(moduleProgressRecords);
      }
    },
  );
}

/// Static accessor mirroring the former `IsarService.instance` pattern so
/// repositories need no constructor wiring.
class AppDatabaseService {
  AppDatabaseService._();

  static late AppDatabase instance;
}
