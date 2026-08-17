import 'package:brew_path/core/utils/date_utils.dart';
import 'package:brew_path/features/learn/domain/course_completion.dart';
import 'package:brew_path/features/learn/domain/course_completion_providers.dart';
import 'package:brew_path/shared/repositories/snapshot_repository.dart';
import 'package:brew_path/shared/storage/account_wipe.dart';
import 'package:brew_path/shared/storage/app_database.dart';
import 'package:brew_path/shared/storage/snapshot/progress_snapshot.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/snapshot_generators.dart';

/// The ack round trip against the real snapshot store: written once, dated,
/// idempotent, and cleared only by whatever clears the reset scope.
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

  test('acking writes the key dated with the local day', () async {
    final now = DateTime(2026, 8, 17, 21, 30);

    await ackCourseCompletion(repo, now);

    final stored = await repo.read();
    expect(stored.clearedByReset.acks[courseCompleteAckKey], epochDay(now));
  });

  test('acking twice keeps the first day — the moment stays one-off', () async {
    await ackCourseCompletion(repo, DateTime(2026, 8, 17));
    await ackCourseCompletion(repo, DateTime(2026, 9, 2));

    final stored = await repo.read();
    expect(
      stored.clearedByReset.acks[courseCompleteAckKey],
      epochDay(DateTime(2026, 8, 17)),
    );
  });

  test('acking preserves the rest of the snapshot', () async {
    final seeded = (await repo.read()).copyWith(deviceId: 'phone');
    await repo.write(seeded);

    await ackCourseCompletion(repo, DateTime(2026, 8, 17));

    final stored = await repo.read();
    expect(stored.deviceId, 'phone');
  });

  // `withAck` re-lists every field of the scope by hand; a field it forgot
  // would be silently dropped by the very write that celebrates finishing.
  // A fully-populated scope pins that down.
  test('acking a fully-populated scope drops none of it', () async {
    final populated = SnapshotGen(7).progress();
    await repo.write(ProgressSnapshot(clearedByReset: populated));

    await ackCourseCompletion(repo, DateTime(2026, 8, 17));

    final stored = (await repo.read()).clearedByReset;
    final expected = Map<String, dynamic>.from(populated.toJson())
      ..['acks'] = {
        ...populated.acks,
        courseCompleteAckKey: epochDay(DateTime(2026, 8, 17)),
      };
    expect(stored.toJson(), expected);
  });

  test('Reset Progress clears the ack, re-arming the moment', () async {
    await ackCourseCompletion(repo, DateTime(2026, 8, 17));

    await AccountWipe().resetProgress();

    final stored = await repo.read();
    expect(stored.clearedByReset.hasAck(courseCompleteAckKey), isFalse);
  });
}
