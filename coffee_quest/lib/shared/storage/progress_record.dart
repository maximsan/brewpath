import 'package:isar/isar.dart';

part 'progress_record.g.dart';

@collection
class ProgressRecord {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String lessonId;

  late bool isCompleted;
  late int xpEarned;
  late DateTime completedAt;
}
