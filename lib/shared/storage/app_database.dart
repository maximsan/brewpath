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

  /// Whether the lesson's full payout has already been awarded.
  ///
  /// ⚠️ **Dead: always `true`.** A completion row only ever exists once the
  /// lesson has paid, so the flag never distinguished anything. Dropped by the
  /// destructive rebuild (#79); a column cannot go while the mapper round-trips
  /// it.
  BoolColumn get fullXpAwarded => boolean().withDefault(const Constant(true))();

  /// Graded cards answered right in the lesson's best run.
  ///
  /// Kept as the pair `correctCount` / `gradedTotal`, not a percentage: the
  /// mastery band needs the wrong-answer count and the gauge the ratio. A row
  /// with `gradedTotal == 0` holds no score.
  IntColumn get correctCount => integer().withDefault(const Constant(0))();

  /// Graded cards in the lesson's best run; `0` means unscored.
  IntColumn get gradedTotal => integer().withDefault(const Constant(0))();

  /// Calendar day the per-day practice reward was last paid for this lesson.
  ///
  /// ⚠️ **Dead: nothing writes it.** The reward was retired with #160 —
  /// replays pay zero (§5.1). Keep Sharp's "was a lesson replayed today?"
  /// derivation used to read this stamp and now reads the day's activity
  /// entries instead, so no rule depends on it. Dropped by #79.
  DateTimeColumn get lastPracticeXpDate => dateTime().nullable()();
}

/// One row per module whose module-completion bonus was awarded. `moduleId` is
/// unique so the bonus was granted at most once per module.
///
/// ⚠️ **Dead table** — see `ModuleProgressRepository`. Dropped by #79.
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

  /// The learner's running points total.
  ///
  /// ⚠️ **Dead: nothing reads or writes it.** The total is derived from the
  /// completion rows and the snapshot's logged challenges (#160) — a counter is
  /// a second copy of a derivable fact. Dropped by #79.
  IntColumn get totalXp => integer()();

  /// Whether the user has completed the post-install onboarding flow.
  /// Defaults to `false` so rows migrated from schema v2 force the gate.
  BoolColumn get onboardingCompleted =>
      boolean().withDefault(const Constant(false))();

  /// The onboarding goal. Nothing reads or writes it since ADR-0010 moved the
  /// question to v2 and its screen was parked; the column stays for the
  /// reason that ADR gives.
  TextColumn get onboardingGoal => text().nullable()();

  /// The selected brewer. Same as [onboardingGoal].
  TextColumn get onboardingBrewer => text().nullable()();

  /// Appearance preference — `system` / `light` / `dark`, persisted as the
  /// enum's storage string. Device-local: never written to the sync snapshot,
  /// because two devices the same person owns may legitimately differ.
  TextColumn get themeMode => text().withDefault(const Constant('dark'))();

  /// Whether the learner has answered the Tour's intro overlay. Written when
  /// either button is pressed, so abandoning mid-tour never re-arms it.
  ///
  /// Fate-shares with [onboardingCompleted]: `AccountWipe.resetProgress`
  /// keeps both, `SettingsRepository.deleteAll` and
  /// `OnboardingRepository.resetOnboarding` clear both. Device-local.
  BoolColumn get tourSeen => boolean().withDefault(const Constant(false))();

  /// Micro-tip ids the learner has been shown, comma-separated; empty for
  /// none. Under [tourSeen]'s wipe rule (#342): not progress, so it survives
  /// Reset and goes with Delete Account. One column rather than one per tip,
  /// because the guide layer names the set; unknown ids are kept as read, so
  /// an older build never trims a newer device's record. Device-local.
  TextColumn get tipsSeen => text().withDefault(const Constant(''))();

  /// What the learner asked to be called, or null when they did not say.
  ///
  /// Nullable rather than defaulted to a placeholder: "no name given" and "the
  /// name is empty" are the same fact to the greeting, and only one of them
  /// needs representing.
  TextColumn get learnerName => text().nullable()();

  /// Whether the learner asked for a daily reminder. Off by default.
  ///
  /// Stored, not yet acted on: nothing schedules from this bit, and whether
  /// reminders ship at all is unruled; the platform work is #443. Device-local.
  BoolColumn get notificationsEnabled =>
      boolean().withDefault(const Constant(false))();

  /// The time of day the reminder is set for, as one of the design's eight
  /// slots.
  ///
  /// Nullable rather than defaulted: "never chose a time" is a different fact
  /// from "chose 8:00 AM", and the row reads *Off* for the first.
  TextColumn get dailyReminderTime => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// The learner's whole progress state, as one JSON value in one row.
///
/// One blob on purpose: a merged snapshot arrives as a whole object, and
/// decomposing it into rows would put merge semantics where no merge test
/// reaches (an insert-or-ignore resurrects removed favourites; an upsert on
/// the best result becomes last-writer-wins). No query here needs a join.
@DataClassName('SnapshotRow')
class ProgressSnapshots extends Table {
  IntColumn get id => integer()();

  /// The snapshot, encoded. Unknown keys ride along inside it untouched, so a
  /// build that has never heard of a field still writes it back.
  TextColumn get payload => text()();

  @override
  Set<Column> get primaryKey => {id};
}

/// The one row saying when this account began — Profile's `Joined` line, ruled
/// by [ADR-0013](../../../docs/adr/0013-the-joined-line-dates-the-install-and-old-devices-are-not-back-dated.md).
/// Its own table, not a column on [UserSettings], whose row does not exist
/// until the learner chooses something: here the row's existence is the fact,
/// and its absence sends the line to its fallback.
@DataClassName('InstallRow')
class AppInstalls extends Table {
  /// Primary-key id of the singleton install row.
  static const int singletonId = 1;

  IntColumn get id => integer()();

  /// The instant the database was created, which is the app's first run.
  DateTimeColumn get installedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    ProgressRecords,
    CardRecords,
    UserSettings,
    ModuleProgressRecords,
    ProgressSnapshots,
    AppInstalls,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// Production opens a platform DB via drift_flutter; tests pass
  /// `NativeDatabase.memory()`. The on-disk name `coffee_quest` is not renamed
  /// with the package: renaming orphans the existing database. [clock] makes
  /// the install stamp a test input; positional because Dart forbids optional
  /// positional and named parameters together and `executor` is positional.
  AppDatabase([QueryExecutor? executor, DateTime Function()? clock])
    : _clock = clock ?? DateTime.now,
      super(executor ?? driftDatabase(name: 'coffee_quest'));

  final DateTime Function() _clock;

  /// Schema version that added the onboarding columns to `user_settings`.
  static const int _onboardingColumnsVersion = 3;

  /// Schema version that added the appearance preference.
  static const int _themeModeVersion = 4;

  /// Schema version that replaced the `bestScore` percentage with the
  /// `{correctCount, gradedTotal}` pair.
  static const int _masteryPairVersion = 5;

  /// Schema version that added the progress-snapshot row: v6, not the "v4"
  /// the decisions say, because the appearance preference took 4 and the
  /// mastery pair 5, and a version regression breaks Drift's migration check.
  static const int _snapshotRowVersion = 6;

  /// Schema version that dropped `streakDays` and `lastActivityDate`, once
  /// the streak became a fold over the snapshot's active-day set and
  /// `StreakService` was deleted.
  static const int _dropStreakColumnsVersion = 7;

  /// Schema version that added the Tour's `tourSeen` bit.
  static const int _tourSeenVersion = 8;

  /// Schema version that added the learner's chosen name.
  static const int _learnerNameVersion = 9;

  /// Schema version that added the daily reminder's two settings.
  static const int _dailyReminderVersion = 10;

  /// Schema version that added the install stamp.
  static const int _installStampVersion = 11;

  /// Schema version that added the micro-tips' seen list.
  static const int _tipsSeenVersion = 12;

  /// The current version is whichever migration landed last.
  static const int _schemaVersion = _tipsSeenVersion;

  @override
  int get schemaVersion => _schemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    // A created database *is* the install, so this is the one place that can
    // record it without guessing (ADR-0013).
    onCreate: (m) async {
      await m.createAll();
      await into(appInstalls).insert(
        AppInstallsCompanion.insert(
          id: const Value(AppInstalls.singletonId),
          installedAt: _clock(),
        ),
      );
    },
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
      // v2 → v3: onboarding columns on user_settings. Guarded by the version
      // these landed in, not `_schemaVersion`: the old `from < _schemaVersion`
      // re-ran the adds for a device already at v3 and failed on the
      // duplicate column.
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
      // pair. Recreating the table adds the pair and drops the old column; no
      // `columnTransformer`, because a first-try accuracy over unlimited
      // retries cannot become a one-shot grade. Old rows read as unscored.
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

      // v5 → v6: the progress-snapshot row. Additive only: the tables it
      // replaces were still read, so their dead columns dropped later, at v7.
      if (from < _snapshotRowVersion) {
        await m.createTable(progressSnapshots);
      }

      // v6 → v7: `streakDays` and `lastActivityDate` go, the drop v6 deferred.
      // Nothing converts: the values on disk are `0` and `NULL`. Dropped by
      // name, not by a `TableMigration` rebuild, which copies the table's
      // *current* definition and so made this step fail on `tour_seen` once
      // v8 added it (#273). Neither column is indexed or constrained, which is
      // what SQLite needs to drop one in place.
      if (from < _dropStreakColumnsVersion) {
        await m.dropColumn(userSettings, 'streak_days');
        await m.dropColumn(userSettings, 'last_activity_date');
      }

      // v7 → v8: the Tour's `tourSeen` bit, defaulted rather than backfilled:
      // a device upgrading here was never offered the Tour, so `false` is
      // true for it. One-sided like every step: it needed a lower bound only
      // while v6 → v7 rebuilt the table from the current definition (#273).
      if (from < _tourSeenVersion) {
        await m.addColumn(userSettings, userSettings.tourSeen);
      }

      // v8 → v9: the name the learner is greeted by. Purely additive, and
      // nullable, so every existing device arrives with "no name given" —
      // which is the truth for them, and what the greeting already falls back
      // to.
      if (from < _learnerNameVersion) {
        await m.addColumn(userSettings, userSettings.learnerName);
      }

      // v9 -> v10: the daily reminder's switch and its time. Additive, and
      // both arrive as "not asked for" — off, with no time — which is the
      // truth for every device that upgrades into them.
      if (from < _dailyReminderVersion) {
        await m.addColumn(userSettings, userSettings.notificationsEnabled);
        await m.addColumn(userSettings, userSettings.dailyReminderTime);
      }

      // v10 → v11: the install stamp's table, created **empty**.
      //
      // The emptiness is the point, not an oversight. This device installed
      // the app before anything recorded when, and the only instant available
      // here is now — the one answer that is certainly wrong (ADR-0013).
      if (from < _installStampVersion) {
        await m.createTable(appInstalls);
      }

      // v11 → v12: the micro-tips' seen list. Additive, and defaulted to the
      // empty list rather than backfilled: a device upgrading into this version
      // has been shown no tip, so "none" is the true value for it.
      if (from < _tipsSeenVersion) {
        await m.addColumn(userSettings, userSettings.tipsSeen);
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
