import 'dart:io';

import 'package:brew_path/features/saved/domain/saved_key.dart';
import 'package:brew_path/features/saved/domain/saved_providers.dart';
import 'package:brew_path/shared/repositories/snapshot_repository.dart';
import 'package:brew_path/shared/storage/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// The shelf survives a restart, and a removal survives it too.
///
/// **A real restart**, not a second reader over a live database: the file is
/// closed and reopened between the write and the read, so what is being
/// trusted is the bytes on disk rather than anything still held in memory.
/// The in-memory idiom used elsewhere cannot tell those two apart — it proves
/// the repository caches nothing, which is a weaker claim than this one.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory dir;
  late File file;
  late AppDatabase db;
  final now = DateTime(2026, 8, 23);

  /// Opens the database on disk and points the service at it.
  AppDatabase open() => AppDatabaseService.instance = AppDatabase(
    NativeDatabase(file),
  );

  setUp(() {
    dir = Directory.systemTemp.createTempSync('brewpath_saved_');
    file = File('${dir.path}/progress.sqlite');
    db = open();
  });

  tearDown(() async {
    await db.close();
    dir.deleteSync(recursive: true);
  });

  /// Closes the database and opens it again — the restart.
  Future<Set<String>> restartAndRead() async {
    await db.close();
    db = open();
    return (await SnapshotRepository().read()).clearedByReset.favourites.value;
  }

  test('a bookmark is still there after a restart', () async {
    await toggleSaved(
      SnapshotRepository(),
      key: 't:arabica',
      now: now,
      isPlus: false,
      visible: 0,
    );

    expect(await restartAndRead(), {'t:arabica'});
  });

  test('a removal is still gone after a restart', () async {
    final repo = SnapshotRepository();
    await toggleSaved(
      repo,
      key: 't:arabica',
      now: now,
      isPlus: false,
      visible: 0,
    );
    await toggleSaved(
      repo,
      key: 't:arabica',
      now: now,
      isPlus: false,
      visible: 0,
    );

    expect(await restartAndRead(), isEmpty);
  });

  test('a removal made after a restart also survives the next one', () async {
    await toggleSaved(
      SnapshotRepository(),
      key: 't:arabica',
      now: now,
      isPlus: false,
      visible: 0,
    );
    expect(await restartAndRead(), {'t:arabica'});

    await toggleSaved(
      SnapshotRepository(),
      key: 't:arabica',
      now: now,
      isPlus: false,
      visible: 0,
    );

    expect(await restartAndRead(), isEmpty);
  });

  test('several bookmarks accumulate rather than replace', () async {
    final repo = SnapshotRepository();
    for (final key in ['t:arabica', 't:bloom', 'l:m1l1']) {
      await toggleSaved(repo, key: key, now: now, isPlus: false, visible: 0);
    }

    expect(await restartAndRead(), {'t:arabica', 't:bloom', 'l:m1l1'});
  });

  test(
    'the write stamps the shelf so a peer cannot resurrect a removal',
    () async {
      await toggleSaved(
        SnapshotRepository(),
        key: 't:arabica',
        now: now,
        isPlus: false,
        visible: 0,
      );
      await restartAndRead();

      final stored = (await SnapshotRepository().read()).clearedByReset;
      expect(stored.favourites.updatedAt, now.millisecondsSinceEpoch);
    },
  );

  test('every kind round-trips through the store', () async {
    final repo = SnapshotRepository();
    for (final kind in SavedKind.values) {
      await toggleSaved(
        repo,
        key: formatSavedKey(kind, 'thing'),
        now: now,
        isPlus: false,
        visible: 0,
      );
    }

    expect(await restartAndRead(), {'l:thing', 't:thing', 'g:thing'});
  });
}
