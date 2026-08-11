import 'package:brew_path/shared/storage/app_database.dart';
import 'package:drift/drift.dart';

/// Persisted ledger of which modules have already paid out their
/// module-completion XP, so the bonus is granted at most once per module.
class ModuleProgressRepository {
  AppDatabase get _db => AppDatabaseService.instance;

  /// Whether the module-completion XP has already been granted for [moduleId].
  Future<bool> isModuleXpAwarded(String moduleId) async {
    final row = await (_db.select(
      _db.moduleProgressRecords,
    )..where((t) => t.moduleId.equals(moduleId))).getSingleOrNull();
    return row?.moduleXpAwarded ?? false;
  }

  /// Marks the module-completion XP as granted. Idempotent — the unique
  /// `moduleId` + insert-or-ignore means calling twice stores only one row.
  Future<void> markModuleXpAwarded(String moduleId) async {
    await _db
        .into(_db.moduleProgressRecords)
        .insert(
          ModuleProgressRecordsCompanion.insert(
            moduleId: moduleId,
            moduleXpAwarded: true,
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  /// Wipes the module-XP ledger. Used by the Profile "Reset Progress" action
  /// so module-completion bonuses can be re-earned after a reset.
  Future<void> deleteAll() async {
    await _db.delete(_db.moduleProgressRecords).go();
  }
}
