import 'package:isar/isar.dart';
import 'package:coffee_quest/shared/storage/card_record.dart';
import 'package:coffee_quest/shared/storage/isar_service.dart';

class CardRepository {
  Isar get _isar => IsarService.instance;

  Future<List<String>> getAllCollectedCardIds() async {
    final records = await _isar.cardRecords.where().findAll();
    return records.map((r) => r.cardId).toList();
  }

  Future<bool> isCardCollected(String cardId) async {
    final record =
        await _isar.cardRecords.filter().cardIdEqualTo(cardId).findFirst();
    return record != null;
  }

  /// Idempotent — collecting the same [cardId] twice stores only one record.
  Future<void> collectCard(String cardId) async {
    await _isar.writeTxn(() async {
      final exists =
          await _isar.cardRecords.filter().cardIdEqualTo(cardId).findFirst();
      if (exists != null) return;
      await _isar.cardRecords.put(
        CardRecord()
          ..cardId = cardId
          ..unlockedAt = DateTime.now(),
      );
    });
  }
}
