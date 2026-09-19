import 'package:brew_path/features/saved/domain/saved_providers.dart';
import 'package:brew_path/shared/repositories/snapshot_repository.dart';
import 'package:brew_path/shared/storage/app_database.dart';
import 'package:brew_path/shared/storage/snapshot/progress_snapshot.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

ProgressSnapshot _withFavourites(ProgressSnapshot snapshot, Set<String> keys) =>
    snapshot.copyWith(
      updatedAt: 1,
      clearedByReset: snapshot.clearedByReset.withFavourites(
        keys,
        at: 1,
        writerId: snapshot.deviceId,
      ),
    );

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    AppDatabaseService.instance = db;
    addTearDown(db.close);
  });

  test('the stream opens on what is stored, empty install included', () async {
    final snapshots = SnapshotRepository();

    expect(await snapshots.watch().first, ProgressSnapshot.empty);
  });

  test('a write reaches the stream with nobody announcing it', () async {
    final snapshots = SnapshotRepository();
    final seen = <Set<String>>[];
    final subscription = snapshots.watch().listen(
      (snapshot) => seen.add(snapshot.clearedByReset.favourites.value),
    );
    addTearDown(subscription.cancel);

    await pumpEventQueue();
    await snapshots.write(
      _withFavourites(await snapshots.read(), {'t:arabica'}),
    );
    await pumpEventQueue();

    expect(seen, [
      <String>{},
      {'t:arabica'},
    ]);
  });

  test('a provider follows the database with no invalidate', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final snapshots = SnapshotRepository();
    // A screen holds its watch open; a bare read would let the provider be
    // disposed between the two reads and re-created on the second.
    container.listen(savedKeysProvider, (_, _) {});

    expect(await container.read(savedKeysProvider.future), isEmpty);

    await snapshots.write(
      _withFavourites(await snapshots.read(), {'t:arabica'}),
    );
    await pumpEventQueue();

    expect(container.read(savedKeysProvider).value, {'t:arabica'});
  });
}
