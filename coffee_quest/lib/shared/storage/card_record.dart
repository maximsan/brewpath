import 'package:isar/isar.dart';

part 'card_record.g.dart';

@collection
class CardRecord {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String cardId;

  late DateTime unlockedAt;
}
