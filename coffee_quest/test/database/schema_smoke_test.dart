import 'package:coffee_quest/shared/storage/app_database.dart';
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../generated/schema.dart';
import '../generated/schema_v1.dart';

/// Infrastructure smoke test for the Drift schema-migration harness.
///
/// Not a migration test — there is only schema v1 so far. This verifies the
/// generated [GeneratedHelper] / [SchemaVerifier] pipeline is wired correctly:
/// an empty database can be created at v1, opens without error, and exposes
/// the expected tables.
void main() {
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  test('schema v1 database opens cleanly with the expected tables', () async {
    final connection = await verifier.startAt(1);
    final db = DatabaseAtV1(connection);

    // Force the connection to actually open and execute against the v1 schema.
    await db.customSelect('SELECT 1').get();

    expect(db.schemaVersion, 1);
    expect(db.allTables.length, 3);
    expect(
      db.allTables.map((t) => t.actualTableName).toSet(),
      {'progress_records', 'card_records', 'user_settings'},
    );

    await db.close();
  });

  // Locks in the idempotency invariant that currently lives only in the
  // schema: `progress_records.lessonId` is UNIQUE, which is what makes
  // `saveCompletion`'s insert-or-ignore safe (replaying a completed lesson
  // must not double-count XP/streak). Tested on the real production schema.
  test('progress_records.lessonId UNIQUE rejects duplicate insert', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    Future<void> insertLesson(String lessonId) =>
        db.into(db.progressRecords).insert(
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
