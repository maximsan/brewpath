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

/// Drift schema-migration harness coverage.
///
/// Verifies the generated [GeneratedHelper] / [SchemaVerifier] pipeline: each
/// historical schema opens cleanly, and the real `AppDatabase` migration
/// upgrades a v1 database to the v2 schema.
void main() {
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
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
    await verifier.testWithDataIntegrity(
      oldVersion: 4,
      newVersion: 5,
      createOld: DatabaseAtV4.new,
      createNew: DatabaseAtV5.new,
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

  test('a v5 database upgrades to v6 keeping its rows', () async {
    // Upgrading from the *currently shipped* version, not from a fresh
    // database: developer devices sit on v5, and a migration only ever
    // exercised on an empty database proves nothing about the one case that
    // can lose data.
    await verifier.testWithDataIntegrity(
      oldVersion: 5,
      newVersion: 6,
      createOld: DatabaseAtV5.new,
      createNew: DatabaseAtV6.new,
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
  });
}
