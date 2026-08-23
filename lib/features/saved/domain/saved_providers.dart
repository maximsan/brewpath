import 'package:brew_path/features/saved/domain/saved_key.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:brew_path/shared/repositories/snapshot_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'saved_providers.g.dart';

/// Every key on the Saved shelf, exactly as stored.
///
/// Raw rather than resolved: what a key *points at* needs the content bank,
/// and the two questions have different answers when a saved id no longer
/// exists. The shelf resolves; a bookmark only needs to know whether its own
/// key is in here.
@riverpod
Future<Set<String>> savedKeys(Ref ref) async {
  final snapshots = ref.watch(snapshotRepositoryProvider);
  return (await snapshots.read()).clearedByReset.favourites.value;
}

/// Whether [key] is on the shelf.
@riverpod
Future<bool> isKeySaved(Ref ref, String key) async =>
    (await ref.watch(savedKeysProvider.future)).contains(key);

/// Puts [key] on the shelf, or takes it off.
///
/// A read-modify-write over the whole snapshot, as every other progress write
/// is: the snapshot **is** the record, so there is no partial write to get
/// wrong. Stamping it is what lets a peer that still holds the key lose to
/// this removal rather than resurrect it.
Future<void> toggleSaved(
  SnapshotRepository repository, {
  required String key,
  required DateTime now,
}) async {
  final snapshot = await repository.read();
  final at = now.millisecondsSinceEpoch;
  final next = toggleSavedKey(snapshot.clearedByReset.favourites.value, key);

  await repository.write(
    snapshot.copyWith(
      updatedAt: at,
      clearedByReset: snapshot.clearedByReset.withFavourites(
        next,
        at: at,
        writerId: snapshot.deviceId,
      ),
    ),
  );
}
