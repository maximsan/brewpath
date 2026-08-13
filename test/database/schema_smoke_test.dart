import 'package:brew_path/shared/storage/app_database.dart';
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../generated/schema.dart';
import '../generated/schema_v1.dart' show DatabaseAtV1;
import '../generated/schema_v2.dart' show DatabaseAtV2;
import '../generated/schema_v3.dart' show DatabaseAtV3;
import '../generated/schema_v4.dart' show DatabaseAtV4;

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
}
