import 'package:brew_path/shared/storage/app_database.dart';
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../generated/schema.dart';
import '../generated/schema_v4.dart' show DatabaseAtV4;

/// The columns the v4 → v5 rebuild declares in its `newColumns`.
///
/// Kept here rather than read out of the migration because the point is to
/// fail when the two disagree — a copy that cannot drift is a copy that
/// cannot catch anything.
const _declaredAtV5 = {'correct_count', 'graded_total'};

/// Guards the one table rebuild left in the migration.
///
/// `alterTable(TableMigration(...))` builds the new table from the **current**
/// Dart definition and copies every column it does not list in `newColumns`
/// across by name. A column added to the table later is therefore selected out
/// of an old source table that has none, and every chained upgrade fails on a
/// column the step never mentions — with a raw SQLite error, in a step that
/// predates the change, which reads like a bug in the new column rather than a
/// rule that was missed (#273).
///
/// `user_settings` no longer has this shape: its v6 → v7 step drops the two
/// dead columns **by name**, so nothing there depends on the current
/// definition. `progress_records` cannot take the same treatment — `best_score`
/// is absent on v1 databases and present from v2, and a name-based drop fails
/// on the ones that never had it, which is exactly what the rebuild tolerates.
///
/// So the rebuild stays, and this test is the rule stated where it fires.
void main() {
  test('every column added to progress_records since v4 is declared in the '
      'v4 → v5 rebuild', () async {
    final verifier = SchemaVerifier(GeneratedHelper());
    final old = DatabaseAtV4(await verifier.startAt(4));
    final columnsAtV4 = old.progressRecords.$columns
        .map((column) => column.name)
        .toSet();
    await old.close();

    final current = AppDatabase(NativeDatabase.memory());
    final columnsNow = current.progressRecords.$columns
        .map((column) => column.name)
        .toSet();
    await current.close();

    expect(
      columnsNow.difference(columnsAtV4),
      _declaredAtV5,
      reason:
          'A column on `progress_records` post-dates schema v4 without being '
          'declared in the v4 → v5 `TableMigration`. That rebuild copies every '
          'undeclared column out of the v4 source table, which does not have '
          'this one, so every upgrade from v1–v4 will fail on it. Add it to '
          "that step's `newColumns` so it lands on its default instead of "
          'being copied, then add it to `_declaredAtV5` here.',
    );
  });
}
