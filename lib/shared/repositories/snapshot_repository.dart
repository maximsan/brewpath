import 'dart:convert';

import 'package:brew_path/shared/storage/app_database.dart';
import 'package:brew_path/shared/storage/snapshot/progress_snapshot.dart';
import 'package:drift/drift.dart';

/// Reads and writes the single progress-snapshot row.
///
/// The repository is deliberately thin: it moves the snapshot between its Dart
/// form and one row of text, and owns no merge logic at all. Every conflict
/// decision belongs to `mergeSnapshot`, which is pure and therefore testable
/// without any of this — putting even part of it here would create a second
/// home for merge semantics that no test of the merge could reach.
class SnapshotRepository {
  AppDatabase get _db => AppDatabaseService.instance;

  /// Primary-key id of the singleton snapshot row.
  static const int snapshotId = 1;

  /// The stored snapshot, or [ProgressSnapshot.empty] on a fresh install.
  ///
  /// A row that fails to parse also reads as empty rather than throwing. The
  /// snapshot arrives from an unvalidated key-value store, so a truncated or
  /// mangled payload must cost the learner their progress at worst — never the
  /// ability to open the app.
  Future<ProgressSnapshot> read() async {
    final row = await (_db.select(
      _db.progressSnapshots,
    )..where((row) => row.id.equals(snapshotId))).getSingleOrNull();
    if (row == null) return ProgressSnapshot.empty;

    try {
      return ProgressSnapshot.fromJson(
        jsonDecode(row.payload) as Map<String, dynamic>,
      );
    } on FormatException {
      return ProgressSnapshot.empty;
    }
  }

  /// Writes [snapshot] over the stored one.
  ///
  /// Whole-value, never field-by-field: the snapshot *is* the record, so there
  /// is no partial write to get wrong and nothing to reconcile between columns.
  Future<void> write(ProgressSnapshot snapshot) async {
    await _db
        .into(_db.progressSnapshots)
        .insertOnConflictUpdate(
          ProgressSnapshotsCompanion.insert(
            id: const Value(snapshotId),
            payload: jsonEncode(snapshot.toJson()),
          ),
        );
  }
}
