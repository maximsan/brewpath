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

  /// Records a lesson's first completion. Idempotent — the unique `lessonId` +
  /// insert-or-ignore means calling twice for the same lesson stores only one
  /// record. [score] is the run's first-try accuracy (0–100).
  Future<void> saveCompletion({
    required String lessonId,
    required int xpEarned,
    required int score,
  }) async {
    await _db
        .into(_db.progressRecords)
        .insert(
          ProgressRecordsCompanion.insert(
            lessonId: lessonId,
            isCompleted: true,
            xpEarned: xpEarned,
            completedAt: DateTime.now(),
            fullXpAwarded: const Value(true),
            bestScore: Value(score),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  /// Persists a mutated [ProgressRecord] (used by review to update
  /// `bestScore` / `lastPracticeXpDate`). Keyed by `lessonId`; no-op if the
  /// lesson has no completion row yet.
  Future<void> saveProgress(ProgressRecord record) async {
    await (_db.update(
      _db.progressRecords,
    )..where((t) => t.lessonId.equals(record.lessonId))).write(
      ProgressRecordsCompanion(
        isCompleted: Value(record.isCompleted),
        xpEarned: Value(record.xpEarned),
        completedAt: Value(record.completedAt),
        fullXpAwarded: Value(record.fullXpAwarded),
        bestScore: Value(record.bestScore),
        lastPracticeXpDate: Value(record.lastPracticeXpDate),
      ),
    );
  }

  /// Wipes every completion record. Used by the Profile "Reset Progress"
  /// action — repository-level operation so no XP/streak/card state leaks
  /// across a reset.
  Future<void> deleteAll() async {
    await _db.delete(_db.progressRecords).go();
  }

  ProgressRecord _toDto(ProgressRow r) => ProgressRecord(
    id: r.id,
    lessonId: r.lessonId,
    isCompleted: r.isCompleted,
    xpEarned: r.xpEarned,
    completedAt: r.completedAt,
    fullXpAwarded: r.fullXpAwarded,
    bestScore: r.bestScore,
    lastPracticeXpDate: r.lastPracticeXpDate,
  );
}
