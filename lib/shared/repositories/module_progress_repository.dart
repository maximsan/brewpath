import 'package:brew_path/shared/storage/app_database.dart';
import 'package:drift/drift.dart';

/// Persisted ledger of which modules have already paid out their
/// module-completion bonus, so it was granted at most once per module.
///
/// ⚠️ **Dead. Nothing reads or writes it any more.** The bonus it guarded was
/// retired with #160 — a module pays nothing, and what the module moment hands
/// over is its Field Guide card, which needs no ledger because collecting a
/// card already held is a no-op. Kept only so the account wipe can still clear
/// rows written by an earlier build; the table goes with the destructive
/// rebuild (#79).
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
