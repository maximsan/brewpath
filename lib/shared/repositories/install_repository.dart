import 'package:brew_path/shared/storage/app_database.dart';
import 'package:drift/drift.dart';

/// Reads and rewrites the single install row — when this account began.
///
/// The row is written by `AppDatabase`'s `onCreate`, because creating the
/// database is the app's first run. The only other writer is Delete Account,
/// which begins a new account; see
/// [ADR-0013](../../../docs/adr/0013-the-joined-line-dates-the-install-and-old-devices-are-not-back-dated.md).
class InstallRepository {
  AppDatabase get _db => AppDatabaseService.instance;

  /// When this account began, or null on a database created before schema v11.
  Future<DateTime?> installedAt() async {
    final row =
        await (_db.select(
              _db.appInstalls,
            )..where((row) => row.id.equals(AppInstalls.singletonId)))
            .getSingleOrNull();

    return row?.installedAt;
  }

  /// Restamps the row, as Delete Account does.
  ///
  /// **Delete Account only.** Every other caller would be moving a date that
  /// is already right, which is how a recorded install turns into today's.
  ///
  /// An upsert rather than an update: a device that installed before schema
  /// v11 reaches a delete with no row at all, and it must end it with one like
  /// any other.
  Future<void> recordInstall(DateTime at) async {
    await _db
        .into(_db.appInstalls)
        .insertOnConflictUpdate(
          AppInstallsCompanion.insert(
            id: const Value(AppInstalls.singletonId),
            installedAt: at,
          ),
        );
  }
}
