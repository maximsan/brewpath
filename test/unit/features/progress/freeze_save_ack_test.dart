import 'package:brew_path/features/progress/domain/freeze_save_notice.dart';
import 'package:brew_path/features/progress/domain/freeze_save_notice_providers.dart';
import 'package:brew_path/shared/repositories/snapshot_repository.dart';
import 'package:brew_path/shared/storage/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// The save-notice ack round trip against the real snapshot store: the value
/// is the covered day, raise-only, so no replay path can resurrect a notice.
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

  test('acking stores the covered day under the notice key', () async {
    await ackFreezeSave(repo, 20654, DateTime(2026, 8, 19, 21));

    final stored = await repo.read();
    expect(stored.clearedByReset.acks[freezeSaveAckKey], 20654);
  });

  test('an older covered day never lowers the acknowledgement', () async {
    await ackFreezeSave(repo, 20654, DateTime(2026, 8, 19));
    await ackFreezeSave(repo, 20650, DateTime(2026, 8, 20));

    final stored = await repo.read();
    expect(stored.clearedByReset.acks[freezeSaveAckKey], 20654);
  });

  test('a newer covered day replaces the acknowledgement', () async {
    await ackFreezeSave(repo, 20650, DateTime(2026, 8, 15));
    await ackFreezeSave(repo, 20654, DateTime(2026, 8, 19));

    final stored = await repo.read();
    expect(stored.clearedByReset.acks[freezeSaveAckKey], 20654);
  });
}
