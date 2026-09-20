import 'dart:async';
import 'dart:convert';

import 'package:brew_path/shared/storage/app_database.dart';
import 'package:brew_path/shared/storage/snapshot/progress_snapshot.dart';
import 'package:drift/drift.dart';

/// Reads and writes the single progress-snapshot row.
///
/// Deliberately thin: it moves the snapshot between its Dart form and one row
/// of text, and owns no merge logic. Every conflict decision belongs to
/// `mergeSnapshot`, which is pure and so testable without any of this.
class SnapshotRepository {
  AppDatabase get _db => AppDatabaseService.instance;

  /// Primary-key id of the singleton snapshot row.
  static const int snapshotId = 1;

  /// The snapshot as it stands, once — for a **write path**, never a screen.
  ///
  /// A read-modify-write needs the value at the instant it edits it, which a
  /// stream cannot give: its latest delivered value may already be behind. A
  /// screen that reads this instead goes stale the moment anything writes, and
  /// only a hand-written announcement would bring it back (ADR-0031).
  Future<ProgressSnapshot> read() async {
    final row = await _row().getSingleOrNull();
    return _parse(row);
  }

  /// Every version written after a listener subscribes — for a **screen**,
  /// which pairs it with one [read] for what is stored now.
  ///
  /// Announced by [write], the one door every change goes through, so no
  /// caller owes an announcement and none can forget one. Static because two
  /// instances address the same row and must be the same conversation.
  Stream<ProgressSnapshot> get changes => _changes.stream;

  static final StreamController<ProgressSnapshot> _changes =
      StreamController<ProgressSnapshot>.broadcast();

  SimpleSelectStatement<$ProgressSnapshotsTable, SnapshotRow> _row() =>
      _db.select(_db.progressSnapshots)
        ..where((row) => row.id.equals(snapshotId));

  /// [ProgressSnapshot.empty] for a fresh install, and for a row that fails to
  /// parse: the payload is unvalidated, so a mangled one must cost the learner
  /// their progress at worst, never the ability to open the app.
  ProgressSnapshot _parse(SnapshotRow? row) {
    if (row == null) return ProgressSnapshot.empty;
    try {
      return ProgressSnapshot.fromJson(
        jsonDecode(row.payload) as Map<String, dynamic>,
      );
    } on FormatException {
      return ProgressSnapshot.empty;
    }
  }

  /// Writes [snapshot] over the stored one, and says so on [changes].
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
    _changes.add(snapshot);
  }
}
