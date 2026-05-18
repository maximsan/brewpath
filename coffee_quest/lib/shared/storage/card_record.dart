/// Mutable DTO for a collected-card row. See [ProgressRecord] for rationale.
class CardRecord {
  CardRecord({this.id = 0, required this.cardId, required this.unlockedAt});

  int id;
  String cardId;
  DateTime unlockedAt;
}
