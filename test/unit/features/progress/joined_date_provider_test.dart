// Profile's closing line, seen from the two kinds of device that reach it.
//
// The rule itself is `deriveJoinedDate`'s and is unit-tested beside it; this
// pins the wiring, because the failure it guards against is silent — a device
// installed before the stamp shipped simply loses the line, or is told it
// joined today, and nothing throws anywhere.
import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:brew_path/features/progress/domain/progress_providers.dart';
import 'package:brew_path/shared/repositories/progress_repository.dart';
import 'package:brew_path/shared/storage/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final firstRun = DateTime(2026, 3, 14, 9, 30);

  late AppDatabase db;
  late ProgressRepository progress;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory(), () => firstRun);
    AppDatabaseService.instance = db;
    progress = ProgressRepository();
  });
  tearDown(() async => db.close());

  /// Empties the install table, which is the shape of every database created
  /// before schema v11 — the migration adds the table and writes no row.
  Future<void> asAnInstallPredatingTheStamp() => db.delete(db.appInstalls).go();

  /// A completion record backdated to [at]; `saveCompletion` stamps now.
  Future<void> completedOn(String lessonId, DateTime at) async {
    await progress.saveCompletion(
      lessonId: lessonId,
      xpEarned: 10,
      mastery: const MasteryResult(correct: 1, total: 1),
    );
    final record = (await progress.getByLessonId(lessonId))!;
    record.completedAt = at;
    await progress.saveProgress(record);
  }

  Future<DateTime?> joined() {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    return container.read(joinedDateProvider.future);
  }

  test('a fresh install reads its own first run', () async {
    expect(await joined(), firstRun);
  });

  test('a fresh install reads it before doing anything at all', () async {
    // The line used to be absent here, because there was no activity to read.
    expect(await joined(), isNotNull);
  });

  test('the stamp beats a first lesson finished weeks later', () async {
    // The divergence the ticket is about: installed in March, started in July.
    await completedOn('m1l1', DateTime(2026, 7, 2, 12));

    expect(await joined(), firstRun);
  });

  test('an install predating the stamp falls back to its first day', () async {
    await asAnInstallPredatingTheStamp();
    await completedOn('m1l1', DateTime(2026, 7, 2, 12));

    expect(await joined(), DateTime(2026, 7, 2));
  });

  test('nothing recorded and nothing done reads as no line', () async {
    await asAnInstallPredatingTheStamp();

    expect(await joined(), isNull);
  });
}
