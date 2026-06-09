import 'package:coffee_quest/shared/storage/progress_record.dart' show ProgressRecord;

/// Mutable DTO for a collected-card row. See [ProgressRecord] for rationale.
class CardRecord {
  CardRecord({required this.cardId, required this.unlockedAt, this.id = 0});

  int id;
  String cardId;
  DateTime unlockedAt;
}
