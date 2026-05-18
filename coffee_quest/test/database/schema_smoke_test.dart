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
}
