import 'package:coffee_quest/shared/storage/app_database.dart';
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../generated/schema.dart';
import '../generated/schema_v1.dart';
import '../generated/schema_v2.dart';

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

  test('AppDatabase migrates a v1 database to the v2 schema', () async {
    final connection = await verifier.startAt(1);
    final db = AppDatabase(connection);

    // Runs the real onUpgrade and asserts the result matches the v2 schema.
    await verifier.migrateAndValidate(db, 2);

    await db.close();
  });

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
