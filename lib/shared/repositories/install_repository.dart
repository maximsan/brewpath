import 'package:brew_path/shared/storage/app_database.dart';
import 'package:drift/drift.dart';

/// Reads and rewrites the single install row — when this account began.
///
/// The row is written once, by `AppDatabase`'s `onCreate`, because creating
/// the database is the app's first run. Nothing else stamps it on a schedule
/// or on demand: a second writer is how a recorded date turns into today's.
class InstallRepository {
  AppDatabase get _db => AppDatabaseService.instance;

  /// Primary-key id of the singleton install row.
  static const int installId = 1;

  /// When this account began, or null on a database created before the stamp
  /// shipped — see `deriveJoinedDate` for what stands in then.
  Future<DateTime?> installedAt() async {
    final row = await (_db.select(
      _db.appInstalls,
    )..where((row) => row.id.equals(installId))).getSingleOrNull();

    return row?.installedAt;
  }

  /// Restamps the row, as Delete Account does.
  ///
  /// **Delete Account only.** A delete leaves the app in the state of a fresh
  /// install — no progress, no preferences, onboarding replayed — and the
  /// joined line has to say the same thing, because the account it dates no
  /// longer exists. Every other caller would be moving a date that is already
  /// right.
  Future<void> recordInstall(DateTime at) async {
    await _db
        .into(_db.appInstalls)
        .insertOnConflictUpdate(
          AppInstallsCompanion.insert(
            id: const Value(installId),
            installedAt: at,
          ),
        );
  }
}
