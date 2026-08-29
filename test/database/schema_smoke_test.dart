import 'package:brew_path/shared/storage/app_database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../generated/schema.dart';
import '../generated/schema_v1.dart' show DatabaseAtV1;
import '../generated/schema_v2.dart' show DatabaseAtV2;
import '../generated/schema_v3.dart' show DatabaseAtV3;
import '../generated/schema_v4.dart' show DatabaseAtV4;
import '../generated/schema_v5.dart' show DatabaseAtV5;
import '../generated/schema_v6.dart' show DatabaseAtV6;
import '../generated/schema_v7.dart' show DatabaseAtV7;
import '../generated/schema_v8.dart' show DatabaseAtV8;
import '../generated/schema_v9.dart' show DatabaseAtV9;

/// Drift schema-migration harness coverage.
///
/// Verifies the generated [GeneratedHelper] / [SchemaVerifier] pipeline: each
/// historical schema opens cleanly, and the real `AppDatabase` migration
/// upgrades a v1 database to the v2 schema.
/// The newest schema that has been dumped to `drift_schemas/`.
///
/// Read from the generated helper rather than written as a literal: every
/// data-integrity case below upgrades *to the current version*, and a literal
/// there means a schema bump silently keeps testing the old target — a bump
/// editing a file that never mentions it. The first test keeps this honest
/// against the app's own `schemaVersion`.
final int _currentVersion = GeneratedHelper.versions.last;

void main() {
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  test('the dumped schemas keep pace with the database', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final declared = db.schemaVersion;
    await db.close();

    expect(
      declared,
      _currentVersion,
      reason:
          'AppDatabase.schemaVersion and the newest file in drift_schemas/ '
          'disagree. Either the version was bumped without dumping the schema '
          '(`dart run drift_dev schema dump …`, then `schema generate …`), or '
          'a schema was dumped without bumping the version. Until they agree, '
          'every migration test below validates against the wrong target.',
    );
  });

  test('schema v1 database opens with the expected tables', () async {
    final connection = await verifier.startAt(1);
    final db = DatabaseAtV1(connection);
    await db.customSelect('SELECT 1').get();

    expect(db.schemaVersion, 1);
    expect(db.allTables.map((t) => t.actualTableName).toSet(), {
      'progress_records',
      'card_records',
      'user_settings',
    });

    await db.close();
  });

  test('schema v2 database opens with the module-progress table', () async {
    final connection = await verifier.startAt(2);
    final db = DatabaseAtV2(connection);
    await db.customSelect('SELECT 1').get();

    expect(db.schemaVersion, 2);
    expect(db.allTables.map((t) => t.actualTableName).toSet(), {
      'progress_records',
      'card_records',
      'user_settings',
      'module_progress_records',
    });

    await db.close();
  });

  test('AppDatabase migrates a v1 database to the current schema', () async {
    final connection = await verifier.startAt(1);
    final db = AppDatabase(connection);

    // AppDatabase.schemaVersion has advanced; the chained onUpgrade brings a
    // v1 file all the way up to the current version in one open.
    //
    // Targeting `db.schemaVersion` rather than a literal keeps this honest
    // across future bumps: it asserts the migrated database matches the
    // committed snapshot for whatever the current version is, and stops the
    // test going stale the way a hardcoded 3 just did.
    await verifier.migrateAndValidate(db, db.schemaVersion);

    await db.close();
  });

  test(
    'schema v3 database has the onboarding columns on user_settings',
    () async {
      final connection = await verifier.startAt(3);
      final db = DatabaseAtV3(connection);
      await db.customSelect('SELECT 1').get();

      expect(db.schemaVersion, 3);

      // Confirm the three new columns exist by selecting them.
      final columns = await db
          .customSelect('PRAGMA table_info(user_settings)')
          .get();
      final names = columns.map((r) => r.read<String>('name')).toSet();
      expect(
        names,
        containsAll(<String>[
          'onboarding_completed',
          'onboarding_goal',
          'onboarding_brewer',
        ]),
      );

      await db.close();
    },
  );

  test('AppDatabase migrates a v2 database to the current schema', () async {
    final connection = await verifier.startAt(2);
    final db = AppDatabase(connection);

    await verifier.migrateAndValidate(db, db.schemaVersion);

    await db.close();
  });

  test('schema v4 database has theme_mode on user_settings', () async {
    final connection = await verifier.startAt(4);
    final db = DatabaseAtV4(connection);
    await db.customSelect('SELECT 1').get();

    expect(db.schemaVersion, 4);

    final columns = await db
        .customSelect('PRAGMA table_info(user_settings)')
        .get();
    expect(
      columns.map((r) => r.read<String>('name')),
      contains('theme_mode'),
    );

    await db.close();
  });

  test(
    'AppDatabase migrates a v3 database to v4 and defaults to dark',
    () async {
      final connection = await verifier.startAt(3);
      final db = AppDatabase(connection);

      await verifier.migrateAndValidate(db, db.schemaVersion);

      // The column is added with a default rather than as nullable, so a row
      // written before v4 reads back as the default mood instead of null.
      final rows = await db
          .customSelect(
            "SELECT dflt_value FROM pragma_table_info('user_settings') "
            "WHERE name = 'theme_mode'",
          )
          .get();
      expect(rows.single.read<String>('dflt_value'), "'dark'");

      await db.close();
    },
  );

  // Locks in the idempotency invariant that the schema enforces:
  // `progress_records.lessonId` is UNIQUE, which is what makes
  // `saveCompletion`'s insert-or-ignore safe (replaying a completed lesson
  // must not double-count XP/streak). Tested on the real (v2) schema.
  test('progress_records.lessonId UNIQUE rejects duplicate insert', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    Future<void> insertLesson(String lessonId) => db
        .into(db.progressRecords)
        .insert(
          ProgressRecordsCompanion.insert(
            lessonId: lessonId,
            isCompleted: true,
            xpEarned: 10,
            completedAt: DateTime.now(),
          ),
        );

    await insertLesson('lesson_a');

    // A second plain insert with the same lessonId must violate UNIQUE.
    await expectLater(
      insertLesson('lesson_a'),
      throwsA(
        predicate(
          (e) => e.toString().toUpperCase().contains('UNIQUE'),
          'a UNIQUE constraint violation',
        ),
      ),
    );

    final rows = await db.select(db.progressRecords).get();
    expect(rows.length, 1, reason: 'duplicate must not have been written');
  });

  test(
    'schema v5 database replaces best_score with the mastery pair',
    () async {
      final connection = await verifier.startAt(5);
      final db = DatabaseAtV5(connection);
      final cols = await db
          .customSelect('PRAGMA table_info(progress_records)')
          .get();
      final names = cols.map((r) => r.read<String>('name')).toSet();

      expect(names, containsAll(<String>['correct_count', 'graded_total']));
      expect(names, isNot(contains('best_score')));

      await db.close();
    },
  );

  test('a v4 row carrying a best_score migrates to an unscored pair', () async {
    // The old percentage is deliberately not converted: it measured first-try
    // accuracy over all steps with unlimited retries, where grading is one-shot
    // over graded cards. A legacy row therefore lands on {0, 0} and reads as
    // unscored — exactly the neutral empty node the design draws for a lesson
    // finished without a stored score, rather than a fabricated fill.
    //
    // Targeted at the *current* version rather than at 5. `openTestedDatabase`
    // is the real `AppDatabase`, which always migrates as far as it goes, so a
    // run validated against the v5 snapshot starts failing the moment a v6
    // exists. The conversion under test is unchanged by the later steps, so
    // asserting it after the full chain proves the same thing and keeps
    // proving it. **A schema bump means retargeting this and the test below.**
    await verifier.testWithDataIntegrity(
      oldVersion: 4,
      newVersion: _currentVersion,
      createOld: DatabaseAtV4.new,
      createNew: (executor) =>
          GeneratedHelper().databaseForVersion(executor, _currentVersion),
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) => batch.insert(
        oldDb.progressRecords,
        RawValuesInsertable<dynamic>({
          'lesson_id': const Variable<String>('lesson_legacy'),
          'is_completed': const Variable<bool>(true),
          'xp_earned': const Variable<int>(50),
          'completed_at': Variable<DateTime>(DateTime(2026)),
          'full_xp_awarded': const Variable<bool>(true),
          'best_score': const Variable<int>(80),
        }),
      ),
      validateItems: (newDb) async {
        // The generated snapshot classes cannot map rows onto data classes
        // ("TableInfo.map in schema verification code"), so read raw columns.
        final rows = await newDb
            .customSelect(
              'SELECT correct_count, graded_total, xp_earned '
              'FROM progress_records',
            )
            .get();

        expect(rows, hasLength(1));
        expect(rows.single.read<int>('correct_count'), 0);
        expect(rows.single.read<int>('graded_total'), 0);
        // The rest of the row survives the table rebuild untouched.
        expect(rows.single.read<int>('xp_earned'), 50);
      },
    );
  });

  test('schema v6 database adds the progress-snapshot table', () async {
    final connection = await verifier.startAt(6);
    final db = DatabaseAtV6(connection);
    await db.customSelect('SELECT 1').get();

    expect(db.schemaVersion, 6);
    expect(
      db.allTables.map((t) => t.actualTableName).toSet(),
      contains('progress_snapshots'),
    );

    await db.close();
  });

  test(
    'a v5 database upgrades to the current schema keeping its rows',
    () async {
      // Upgrading from a populated older database, not a fresh one: a migration
      // only ever exercised on an empty database proves nothing about the one
      // case that can lose data. Targeted at the current version for the reason
      // given on the test above.
      await verifier.testWithDataIntegrity(
        oldVersion: 5,
        newVersion: _currentVersion,
        createOld: DatabaseAtV5.new,
        createNew: (executor) =>
            GeneratedHelper().databaseForVersion(executor, _currentVersion),
        openTestedDatabase: AppDatabase.new,
        createItems: (batch, oldDb) => batch.insert(
          oldDb.progressRecords,
          RawValuesInsertable<dynamic>({
            'lesson_id': const Variable<String>('lesson_before_v6'),
            'is_completed': const Variable<bool>(true),
            'xp_earned': const Variable<int>(10),
            'completed_at': Variable<DateTime>(DateTime(2026)),
            'correct_count': const Variable<int>(4),
            'graded_total': const Variable<int>(5),
          }),
        ),
        validateItems: (newDb) async {
          // The v6 step is additive, so the existing row is untouched…
          final rows = await newDb
              .customSelect(
                'SELECT correct_count, graded_total FROM progress_records',
              )
              .get();
          expect(rows, hasLength(1));
          expect(rows.single.read<int>('correct_count'), 4);
          expect(rows.single.read<int>('graded_total'), 5);

          // …and the new table exists and is empty.
          final snapshots = await newDb
              .customSelect('SELECT COUNT(*) AS n FROM progress_snapshots')
              .get();
          expect(snapshots.single.read<int>('n'), 0);
        },
      );
    },
  );

  test('schema v7 database has dropped the dead streak columns', () async {
    final connection = await verifier.startAt(7);
    final db = DatabaseAtV7(connection);
    await db.customSelect('SELECT 1').get();

    expect(db.schemaVersion, 7);

    final columns = await db
        .customSelect('PRAGMA table_info(user_settings)')
        .get();
    final names = columns.map((r) => r.read<String>('name')).toSet();
    expect(names, isNot(contains('streak_days')));
    expect(names, isNot(contains('last_activity_date')));
    // The row still holds what the learner chose.
    expect(
      names,
      containsAll(<String>['theme_mode', 'haptics_enabled', 'total_xp']),
    );

    await db.close();
  });

  test('a v6 database upgrades keeping what the learner chose', () async {
    // The one case that can lose data. Dropping a column means recreating the
    // table, and a recreate that copied the wrong set would silently reset a
    // learner's appearance and onboarding answers — which survive a reset by
    // design, so nothing else would catch it.
    await verifier.testWithDataIntegrity(
      oldVersion: 6,
      newVersion: _currentVersion,
      createOld: DatabaseAtV6.new,
      createNew: (executor) =>
          GeneratedHelper().databaseForVersion(executor, _currentVersion),
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) => batch.insert(
        oldDb.userSettings,
        const RawValuesInsertable<dynamic>({
          'id': Variable<int>(1),
          'haptics_enabled': Variable<bool>(false),
          'sound_enabled': Variable<bool>(false),
          'total_xp': Variable<int>(120),
          // The two being dropped, carrying the values a real device holds:
          // zero and null, because nothing has advanced them since the streak
          // moved onto the day set.
          'streak_days': Variable<int>(0),
          'last_activity_date': Variable<DateTime>(null),
          'onboarding_completed': Variable<bool>(true),
          'onboarding_goal': Variable<String>('brew_better'),
          'onboarding_brewer': Variable<String>('v60'),
          'theme_mode': Variable<String>('light'),
        }),
      ),
      validateItems: (newDb) async {
        final rows = await newDb
            .customSelect(
              'SELECT total_xp, haptics_enabled, sound_enabled, '
              'onboarding_completed, onboarding_goal, onboarding_brewer, '
              'theme_mode FROM user_settings',
            )
            .get();

        expect(rows, hasLength(1));
        final row = rows.single;
        expect(row.read<String>('theme_mode'), 'light');
        expect(row.read<String>('onboarding_goal'), 'brew_better');
        expect(row.read<String>('onboarding_brewer'), 'v60');
        expect(row.read<bool>('onboarding_completed'), true);
        expect(row.read<bool>('haptics_enabled'), false);
        expect(row.read<bool>('sound_enabled'), false);
        expect(row.read<int>('total_xp'), 120);
      },
    );
  });
  test('schema v8 database has tour_seen on user_settings', () async {
    final connection = await verifier.startAt(8);
    final db = DatabaseAtV8(connection);
    await db.customSelect('SELECT 1').get();

    expect(db.schemaVersion, 8);

    final columns = await db
        .customSelect('PRAGMA table_info(user_settings)')
        .get();
    expect(
      columns.map((r) => r.read<String>('name')),
      contains('tour_seen'),
    );

    await db.close();
  });

  test('a v7 database upgrades with the Tour unseen', () async {
    // The added column defaults rather than backfills, and this is what says
    // so: a device that has been through onboarding but predates the Tour must
    // arrive at v8 offered the Tour, not skipped past it. Everything else on
    // the row is asserted alongside, because an additive step that silently
    // rewrote a preference would look identical from the column's side.
    await verifier.testWithDataIntegrity(
      oldVersion: 7,
      newVersion: _currentVersion,
      createOld: DatabaseAtV7.new,
      createNew: (executor) =>
          GeneratedHelper().databaseForVersion(executor, _currentVersion),
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) => batch.insert(
        oldDb.userSettings,
        const RawValuesInsertable<dynamic>({
          'id': Variable<int>(1),
          'haptics_enabled': Variable<bool>(true),
          'sound_enabled': Variable<bool>(false),
          'total_xp': Variable<int>(240),
          'onboarding_completed': Variable<bool>(true),
          'onboarding_goal': Variable<String>('understand_tasting'),
          'onboarding_brewer': Variable<String>('aeropress'),
          'theme_mode': Variable<String>('light'),
        }),
      ),
      validateItems: (newDb) async {
        final rows = await newDb
            .customSelect(
              'SELECT tour_seen, onboarding_completed, onboarding_goal, '
              'theme_mode, total_xp FROM user_settings',
            )
            .get();

        expect(rows, hasLength(1));
        final row = rows.single;
        expect(row.read<bool>('tour_seen'), false);
        // The gate it fate-shares with is untouched by the migration: the two
        // only move together when a *wipe* moves them.
        expect(row.read<bool>('onboarding_completed'), true);
        expect(row.read<String>('onboarding_goal'), 'understand_tasting');
        expect(row.read<String>('theme_mode'), 'light');
        expect(row.read<int>('total_xp'), 240);
      },
    );
  });

  test('schema v9 database has neither reminder column yet', () async {
    final connection = await verifier.startAt(9);
    final db = DatabaseAtV9(connection);

    await expectLater(
      db.customSelect('SELECT notifications_enabled FROM user_settings').get(),
      throwsA(isA<Exception>()),
    );

    await db.close();
  });

  test('a v9 database upgrades with no reminder asked for', () async {
    // Both columns default rather than backfill: a device upgrading into the
    // reminder has never been asked about it, so "off, with no time" is the
    // truth for it — and the row must read *Off* rather than a time that will
    // never arrive. The learner's name is asserted alongside, because an
    // additive step that quietly rewrote the row it touched would look the
    // same from the new columns' side.
    await verifier.testWithDataIntegrity(
      oldVersion: 9,
      newVersion: _currentVersion,
      createOld: DatabaseAtV9.new,
      createNew: (executor) =>
          GeneratedHelper().databaseForVersion(executor, _currentVersion),
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) => batch.insert(
        oldDb.userSettings,
        const RawValuesInsertable<dynamic>({
          'id': Variable<int>(1),
          'haptics_enabled': Variable<bool>(true),
          'sound_enabled': Variable<bool>(true),
          'total_xp': Variable<int>(0),
          'onboarding_completed': Variable<bool>(true),
          'theme_mode': Variable<String>('dark'),
          'tour_seen': Variable<bool>(true),
          'learner_name': Variable<String>('Sam'),
        }),
      ),
      validateItems: (newDb) async {
        final rows = await newDb
            .customSelect(
              'SELECT notifications_enabled, daily_reminder_time, '
              'learner_name FROM user_settings',
            )
            .get();

        expect(rows, hasLength(1));
        final row = rows.single;
        expect(row.read<bool>('notifications_enabled'), false);
        expect(row.readNullable<String>('daily_reminder_time'), null);
        expect(row.read<String>('learner_name'), 'Sam');
      },
    );
  });
}
