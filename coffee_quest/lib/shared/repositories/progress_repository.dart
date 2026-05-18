import 'package:drift/drift.dart';
import 'package:coffee_quest/shared/storage/app_database.dart';
import 'package:coffee_quest/shared/storage/progress_record.dart';

class ProgressRepository {
  AppDatabase get _db => AppDatabaseService.instance;

  Future<List<ProgressRecord>> getAllCompleted() async {
    final rows = await (_db.select(
      _db.progressRecords,
    )..where((t) => t.isCompleted.equals(true))).get();
    return rows.map(_toDto).toList();
  }

  Future<ProgressRecord?> getByLessonId(String lessonId) async {
    final row = await (_db.select(
      _db.progressRecords,
    )..where((t) => t.lessonId.equals(lessonId))).getSingleOrNull();
    return row == null ? null : _toDto(row);
  }

  /// Idempotent — the unique `lessonId` + insert-or-ignore means calling
  /// twice for the same lesson stores only one record.
  Future<void> saveCompletion({
    required String lessonId,
    required int xpEarned,
  }) async {
    await _db
        .into(_db.progressRecords)
        .insert(
          ProgressRecordsCompanion.insert(
            lessonId: lessonId,
            isCompleted: true,
            xpEarned: xpEarned,
            completedAt: DateTime.now(),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  ProgressRecord _toDto(ProgressRow r) => ProgressRecord(
    id: r.id,
    lessonId: r.lessonId,
    isCompleted: r.isCompleted,
    xpEarned: r.xpEarned,
    completedAt: r.completedAt,
  );
}
