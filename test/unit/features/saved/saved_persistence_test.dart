import 'package:brew_path/features/saved/domain/saved_key.dart';
import 'package:brew_path/features/saved/domain/saved_providers.dart';
import 'package:brew_path/shared/repositories/snapshot_repository.dart';
import 'package:brew_path/shared/storage/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// The shelf survives a restart, and a removal survives it too.
///
/// "Restart" here is a **fresh repository re-read**, the same idiom
/// `snapshot_repository_test.dart` uses: the row is what is being trusted,
/// not the object that wrote it.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late SnapshotRepository repo;
  final now = DateTime(2026, 8, 23);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    AppDatabaseService.instance = db;
    repo = SnapshotRepository();
  });

  tearDown(() async => db.close());

  Future<Set<String>> reread() async =>
      (await SnapshotRepository().read()).clearedByReset.favourites.value;

  test('a bookmark is still there after a restart', () async {
    await toggleSaved(repo, key: 't:arabica', now: now);

    expect(await reread(), {'t:arabica'});
  });

  test('a removal is still gone after a restart', () async {
    await toggleSaved(repo, key: 't:arabica', now: now);
    await toggleSaved(repo, key: 't:arabica', now: now);

    expect(await reread(), isEmpty);
  });

  test('several bookmarks accumulate rather than replace', () async {
    for (final key in ['t:arabica', 't:bloom', 'l:m1l1']) {
      await toggleSaved(repo, key: key, now: now);
    }

    expect(await reread(), {'t:arabica', 't:bloom', 'l:m1l1'});
  });

  test(
    'the write stamps the shelf so a peer cannot resurrect a removal',
    () async {
      await toggleSaved(repo, key: 't:arabica', now: now);
      final stored = (await SnapshotRepository().read()).clearedByReset;

      expect(stored.favourites.updatedAt, now.millisecondsSinceEpoch);
    },
  );

  test('every kind round-trips through the store', () async {
    for (final kind in SavedKind.values) {
      await toggleSaved(repo, key: formatSavedKey(kind, 'thing'), now: now);
    }

    expect(await reread(), {'l:thing', 't:thing', 'g:thing'});
  });
}
