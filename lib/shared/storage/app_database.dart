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

  /// Whether the lesson's full payout has already been awarded.
  ///
  /// ⚠️ **Dead: always `true`.** A completion row only ever exists once the
  /// lesson has paid, so the flag never distinguished anything. Dropped by the
  /// destructive rebuild (#79); a column cannot go while the mapper round-trips
  /// it.
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

  /// Was the onboarding goal. **Nothing reads or writes it any more** —
  /// ADR-0010 moved the question to v2 and #407 removed the screen that asked
  /// it, so on every install from that point on it stays null.
  ///
  /// Kept rather than dropped because the schema fixtures under
  /// `test/generated/` are frozen at the versions that carry it: removing the
  /// column is a new schema version and a new fixture, which is worth doing
  /// when the question comes back, not to tidy away two nulls.
  TextColumn get onboardingGoal => text().nullable()();

  /// Was the selected brewer. Left in place for the same reason as
  /// [onboardingGoal], and read by nothing.
  TextColumn get onboardingBrewer => text().nullable()();

  /// Appearance preference — `system` / `light` / `dark`, persisted as the
  /// enum's storage string. Device-local: never written to the sync snapshot,
  /// because two devices the same person owns may legitimately differ.
  TextColumn get themeMode => text().withDefault(const Constant('dark'))();

  /// Whether the learner has answered the Tour's intro overlay.
  ///
  /// Written the moment either button is pressed, so mid-tour abandonment never
  /// re-arms the auto-run. Defaults to `false` so every device migrated from an
  /// earlier schema is offered the Tour once.
  ///
  /// **Fate-shares with [onboardingCompleted].** The two are the app's pair of
  /// "this learner has been shown the introductions" bits, and a wipe that
  /// clears one while keeping the other produces a state no learner can reach
  /// on their own: onboarding replayed with the Tour suppressed, or the
  /// reverse.
  /// The three places that decide are `AccountWipe.resetProgress` (keeps both,
  /// by leaving this row alone), `SettingsRepository.deleteAll` (clears both,
  /// with the row) and `OnboardingRepository.resetOnboarding` (clears both, by
  /// name). Device-local: never written to the progress snapshot.
  BoolColumn get tourSeen => boolean().withDefault(const Constant(false))();

  /// What the learner asked to be called, or null when they did not say.
  ///
  /// Nullable rather than defaulted to a placeholder: "no name given" and "the
  /// name is empty" are the same fact to the greeting, and only one of them
  /// needs representing.
  TextColumn get learnerName => text().nullable()();

  /// Whether the learner asked for a daily reminder.
  ///
  /// Off by default: a notification nobody asked for is the fastest way to be
  /// switched off for good, and the design's own row starts as a choice rather
  /// than as something to undo.
  ///
  /// **Stored, not yet acted on.** Nothing schedules anything from this bit —
  /// whether reminders ship at all has never been ruled, and the platform work
  /// behind it is #443. Device-local either way: a reminder is a property of
  /// the phone in your pocket, not of the account.
  BoolColumn get notificationsEnabled =>
      boolean().withDefault(const Constant(false))();

  /// The time of day the reminder is set for, as one of the design's eight
  /// slots (`prototype/settings.jsx:103`).
  ///
  /// Nullable rather than defaulted: "never chose a time" is a different fact
  /// from "chose 8:00 AM", and the row reads *Off* for the first.
  TextColumn get dailyReminderTime => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// The learner's whole progress state, as one JSON value in one row.
///
/// One row, one blob, deliberately. A merged snapshot arrives from the outside
/// as a *whole object*, so decomposing it back into normalised rows would put
/// merge semantics in a second place no test of the merge can reach — and the
/// obvious SQL is wrong there in the direction that looks right: an
/// insert-or-ignore resurrects every removed favourite forever, and an upsert
/// on the best result turns never-downgrade into plain last-writer-wins.
///
/// The relational benefits are not there to collect either: a dozen fields, no
/// joins, no ordering, no range queries, one writer, and every read is a set
/// membership test against something already in memory.
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
///
/// Its own table rather than a column on [UserSettings], because that row
/// deliberately does not exist until the learner chooses something. Here the
/// row's mere existence carries the fact: a database created before the stamp
/// shipped has none, and that absence is what sends the line to its fallback.
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
  /// `NativeDatabase.memory()`.
  ///
  /// The `coffee_quest` name is the on-disk SQLite filename and is
  /// deliberately **not** renamed with the package: changing it orphans the
  /// existing database rather than migrating it. It is invisible to users, and
  /// the persistence layer is scheduled for a destructive rebuild, so the
  /// rename would cost local data for no gain.
  ///
  /// [clock] is injected so the install stamp written at creation is a test
  /// input rather than the wall clock, the way `AccountWipe` takes its own.
  /// Positional rather than named, unlike that one, because Dart forbids a
  /// signature carrying both optional positional and named parameters and
  /// `executor` is positional at every call site in the suite.
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

  /// Schema version that added the progress-snapshot row.
  ///
  /// ⚠️ **v6, not v4 or v5.** Every source decision says "schema v4,
  /// destructive"; that was true when written and has been overtaken twice —
  /// the appearance preference took 4 and the mastery pair took 5. A version
  /// regression breaks Drift's own migration check outright, so the number is
  /// read from what has actually shipped rather than from the decision text.
  static const int _snapshotRowVersion = 6;

  /// Schema version that dropped `streakDays` and `lastActivityDate`.
  ///
  /// The v5 → v6 step below said the drop "lands with the rewrite that replaces
  /// those readers, not with the table that will eventually make them
  /// redundant". That rewrite has landed: the streak is a fold over the
  /// snapshot's active-day set, `StreakService` is deleted, and nothing has
  /// advanced these two columns since.
  static const int _dropStreakColumnsVersion = 7;

  /// Schema version that added the Tour's `tourSeen` bit.
  static const int _tourSeenVersion = 8;

  /// Schema version that added the learner's chosen name.
  static const int _learnerNameVersion = 9;

  /// Schema version that added the daily reminder's two settings.
  static const int _dailyReminderVersion = 10;

  /// Schema version that added the install stamp.
  static const int _installStampVersion = 11;

  /// The current version is whichever migration landed last.
  static const int _schemaVersion = _installStampVersion;

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

      // v5 → v6: the progress-snapshot row.
      //
      // Purely additive here, on purpose. The normalised progress tables this
      // row replaces are still read by the XP, streak and card layers, and a
      // column cannot be dropped while something reads it — so the drop lands
      // with the rewrite that replaces those readers, not with the table that
      // will eventually make them redundant.
      if (from < _snapshotRowVersion) {
        await m.createTable(progressSnapshots);
      }

      // v6 → v7: `streakDays` and `lastActivityDate` are dropped, which is the
      // drop the step above deferred. Both are dead: the streak derives from
      // the snapshot's active-day set, and nothing has written a non-zero value
      // to either column since that landed.
      //
      // Nothing is converted, because there is nothing to convert — the values
      // on disk are `0` and `NULL`, and the real history they once approximated
      // lives in the day set. Recreating the table drops them by omission from
      // the current definition, the same way `best_score` went at v5.
      // Dropped **by name**, not by recreating the table. A
      // `TableMigration` rebuild would take the table's *current* Dart
      // definition and copy every column on it across by name, which silently
      // makes this step depend on every column `user_settings` will ever
      // have: adding `tourSeen` at v8 made the v7 rebuild select `tour_seen`
      // out of a v7 source table that has none, and every upgrade from v1–v6
      // failed on a column the step never mentions (#273).
      //
      // `dropColumn` names the two dead columns and nothing else, so no future
      // column can reach this step. Both have existed since v1, and neither is
      // indexed or part of a constraint, which is what SQLite requires to drop
      // one in place.
      if (from < _dropStreakColumnsVersion) {
        await m.dropColumn(userSettings, 'streak_days');
        await m.dropColumn(userSettings, 'last_activity_date');
      }

      // v7 -> v8: the Tour's `tourSeen` bit.
      //
      // Additive, and deliberately defaulted rather than backfilled: a device
      // upgrading into this version has never been offered the Tour, so `false`
      // is the true value for it, not a placeholder.
      //
      // One-sided, like every step above. It needed a lower bound as well
      // while v6 → v7 rebuilt the table from the current definition — that
      // rebuild handed anything older than v7 this column already, and adding
      // it twice fails on the duplicate. Dropping by name leaves the step
      // above producing exactly the v7 shape, so every database arriving here
      // lacks the column and every one of them needs the add (#273).
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
    },
  );
}

/// Static accessor mirroring the former `IsarService.instance` pattern so
/// repositories need no constructor wiring.
class AppDatabaseService {
  AppDatabaseService._();

  static late AppDatabase instance;
}
