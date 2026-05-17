import 'package:isar/isar.dart';
import 'package:coffee_quest/shared/storage/isar_service.dart';
import 'package:coffee_quest/shared/storage/progress_record.dart';

class ProgressRepository {
  Isar get _isar => IsarService.instance;

  Future<List<ProgressRecord>> getAllCompleted() async {
    return _isar.progressRecords.filter().isCompletedEqualTo(true).findAll();
  }

  Future<ProgressRecord?> getByLessonId(String lessonId) async {
    return _isar.progressRecords.filter().lessonIdEqualTo(lessonId).findFirst();
  }

  /// Idempotent — calling twice for the same [lessonId] stores only one record.
  Future<void> saveCompletion({
    required String lessonId,
    required int xpEarned,
  }) async {
    await _isar.writeTxn(() async {
      final existing = await _isar.progressRecords
          .filter()
          .lessonIdEqualTo(lessonId)
          .findFirst();
      if (existing != null) return;
      await _isar.progressRecords.put(
        ProgressRecord()
          ..lessonId = lessonId
          ..isCompleted = true
          ..xpEarned = xpEarned
          ..completedAt = DateTime.now(),
      );
    });
  }
}
