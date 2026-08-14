// Self-describing tokens / DTOs / storage infra; no per-member docs.
// ignore_for_file: public_member_api_docs

import 'package:brew_path/shared/repositories/settings_repository.dart'
    show SettingsRepository;
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

  /// Graded cards answered right in the lesson's best run.
  ///
  /// Stored as the pair `correctCount` / `gradedTotal` rather than a
  /// percentage: the mastery band derives from the wrong-answer count
  /// (`gradedTotal - correctCount`) and the node gauge fills to the ratio, and
  /// neither survives being flattened into one number. A row with
  /// `gradedTotal == 0` holds no score and reads as deliberately neutral.
  IntColumn get correctCount => integer().withDefault(const Constant(0))();

  /// Graded cards in the lesson's best run; `0` means unscored.
  IntColumn get gradedTotal => integer().withDefault(const Constant(0))();

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

  /// Whether the user has completed the post-install onboarding flow.
  /// Defaults to `false` so rows migrated from schema v2 force the gate.
  BoolColumn get onboardingCompleted =>
      boolean().withDefault(const Constant(false))();

  /// User-selected onboarding goal (e.g. "brew_better"). Nullable so an
  /// in-progress install does not coerce a value.
  TextColumn get onboardingGoal => text().nullable()();

  /// User-selected brewer (e.g. "v60", "aeropress", "not_sure"). Nullable.
  TextColumn get onboardingBrewer => text().nullable()();

  /// Appearance preference — `system` / `light` / `dark`, persisted as the
  /// enum's storage string. Device-local: never written to the sync snapshot,
  /// because two devices the same person owns may legitimately differ.
  TextColumn get themeMode => text().withDefault(const Constant('dark'))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [ProgressRecords, CardRecords, UserSettings, ModuleProgressRecords],
)
class AppDatabase extends _$AppDatabase {
  /// Production opens a platform DB via drift_flutter; tests pass
  /// `NativeDatabase.memory()`.
  ///
  /// The `coffee_quest` name is the on-disk SQLite filename and is
  /// deliberately **not** renamed with the package: changing it orphans the
  /// existing database rather than migrating it. It is invisible to users, and
  /// the persistence layer is scheduled for a destructive rebuild, so the
  /// rename would cost local data for no gain.
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'coffee_quest'));

  /// Schema version that added the onboarding columns to `user_settings`.
  static const int _onboardingColumnsVersion = 3;

  /// Schema version that added the appearance preference.
  static const int _themeModeVersion = 4;

  /// Schema version that replaced the `bestScore` percentage with the
  /// `{correctCount, gradedTotal}` pair.
  static const int _masteryPairVersion = 5;

  /// The current version is whichever migration landed last.
  static const int _schemaVersion = _masteryPairVersion;

  @override
  int get schemaVersion => _schemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      // v1 → v2: review/mastery columns + the module-XP ledger table.
      if (from < 2) {
        await m.addColumn(progressRecords, progressRecords.fullXpAwarded);
        await m.addColumn(progressRecords, progressRecords.lastPracticeXpDate);
        await m.createTable(moduleProgressRecords);
        // This step also added `bestScore`, which no longer exists on the
        // table. Adding it here is not merely unnecessary but unexpressible —
        // the column is gone from the Dart definition. Skipping it is safe
        // because the v4 → v5 step below recreates this table from the current
        // definition, which drops `best_score` on databases old enough to have
        // it and never wants it on databases that skipped straight past.
      }
      // v2 → v3: onboarding gate + selection columns on user_settings.
      // v2 → v3: onboarding columns on user_settings.
      //
      // Guarded by the version these columns landed in, not `_schemaVersion`.
      // It used to read `from < _schemaVersion`, which was correct only while
      // 3 was the newest version — bumping the constant would have re-run
      // these adds for a device already at v3 and failed on the duplicate
      // column. Each step now names its own version, so the next bump is inert
      // here.
      if (from < _onboardingColumnsVersion) {
        await m.addColumn(userSettings, userSettings.onboardingCompleted);
        await m.addColumn(userSettings, userSettings.onboardingGoal);
        await m.addColumn(userSettings, userSettings.onboardingBrewer);
      }

      // v3 → v4: the appearance preference.
      if (from < _themeModeVersion) {
        await m.addColumn(userSettings, userSettings.themeMode);
      }

      // v4 → v5: `bestScore` gives way to the `{correctCount, gradedTotal}`
      // pair. Recreating the table both adds the new columns and drops the old
      // one; no `columnTransformer` converts anything, because the old value
      // *cannot* be converted — it measured first-try accuracy across all
      // steps with unlimited retries, where grading is one-shot over graded
      // cards. Existing rows land on the pair's zero default and so read as
      // unscored, which is exactly the neutral state the design draws for a
      // lesson finished without a stored score.
      if (from < _masteryPairVersion) {
        await m.alterTable(
          TableMigration(
            progressRecords,
            // Declared as new so the copy step takes their defaults rather
            // than selecting them out of the old table, where they do not
            // exist yet. Everything else copies across by name, and
            // `best_score` is dropped by omission from the new definition.
            newColumns: [
              progressRecords.correctCount,
              progressRecords.gradedTotal,
            ],
          ),
        );
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
