import 'package:brew_path/core/utils/date_utils.dart';
import 'package:brew_path/features/progress/domain/streak_milestone_providers.dart';
import 'package:brew_path/shared/repositories/snapshot_repository.dart';
import 'package:brew_path/shared/storage/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// The milestone ack round trip against the real snapshot store: dated with
/// the presentation day, raise-only.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late SnapshotRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    AppDatabaseService.instance = db;
    repo = SnapshotRepository();
  });

  tearDown(() async {
    await db.close();
  });

  test('acking stores the presentation day', () async {
    final now = DateTime(2026, 8, 19, 20);

    await ackStreakMilestone(repo, now);

    final stored = await repo.read();
    expect(stored.clearedByReset.acks[milestoneAckKey], epochDay(now));
  });

  test('acking twice the same day stays put', () async {
    await ackStreakMilestone(repo, DateTime(2026, 8, 19, 8));
    await ackStreakMilestone(repo, DateTime(2026, 8, 19, 22));

    final stored = await repo.read();
    expect(
      stored.clearedByReset.acks[milestoneAckKey],
      epochDay(DateTime(2026, 8, 19)),
    );
  });

  test('a later milestone raises the acknowledgement', () async {
    await ackStreakMilestone(repo, DateTime(2026, 8, 19));
    await ackStreakMilestone(repo, DateTime(2026, 8, 26));

    final stored = await repo.read();
    expect(
      stored.clearedByReset.acks[milestoneAckKey],
      epochDay(DateTime(2026, 8, 26)),
    );
  });
}
