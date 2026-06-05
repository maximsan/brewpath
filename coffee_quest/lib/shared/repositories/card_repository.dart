import 'package:coffee_quest/shared/storage/app_database.dart';
import 'package:drift/drift.dart';

class CardRepository {
  AppDatabase get _db => AppDatabaseService.instance;

  Future<List<String>> getAllCollectedCardIds() async {
    final rows = await _db.select(_db.cardRecords).get();
    return rows.map((r) => r.cardId).toList();
  }

  Future<bool> isCardCollected(String cardId) async {
    final row = await (_db.select(
      _db.cardRecords,
    )..where((t) => t.cardId.equals(cardId))).getSingleOrNull();
    return row != null;
  }

  /// Idempotent — unique `cardId` + insert-or-ignore stores one record.
  Future<void> collectCard(String cardId) async {
    await _db
        .into(_db.cardRecords)
        .insert(
          CardRecordsCompanion.insert(
            cardId: cardId,
            unlockedAt: DateTime.now(),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  /// Wipes every collected card. Used by the Profile "Reset Progress" action.
  Future<void> deleteAll() async {
    await _db.delete(_db.cardRecords).go();
  }
}
