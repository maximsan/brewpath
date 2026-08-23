import 'package:brew_path/features/dictionary/domain/dictionary_providers.dart';
import 'package:brew_path/features/path/domain/visual_guide_providers.dart';
import 'package:brew_path/features/saved/domain/saved_key.dart';
import 'package:brew_path/features/saved/domain/saved_shelf.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
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

/// The shelf: every saved key resolved against the content, grouped.
///
/// Three banks, one derivation. Guides come from the **earned** shelf rather
/// than the whole bank, so a guide the course has not unlocked cannot be
/// reached from here — the Reference section's rule, honoured once rather than
/// re-invented.
@riverpod
Future<List<SavedGroup>> savedShelf(Ref ref) async {
  // Every watch resolved before the first await: a rebuild mid-flight must not
  // find a watch on the far side of an async gap.
  final keys = ref.watch(savedKeysProvider.future);
  final view = ref.watch(dictionaryViewProvider.future);
  final guides = ref.watch(visualGuideShelfForProvider.future);
  final content = ref.watch(contentRepositoryProvider);

  final dictionary = await view;
  final categories = {
    for (final category in dictionary.categories) category.id: category.label,
  };

  final modules = await content.getModules();

  // Subtitles are written in sentence case; the smallcaps label uppercases
  // them when it draws. Doing it here as well would put the same decision in
  // two places.
  return deriveSavedShelf(
    keys: await keys,
    terms: [
      for (final term in dictionary.terms)
        (
          id: term.id,
          title: term.term,
          subtitle: categories[term.categoryId] ?? 'Term',
        ),
    ],
    // Course order comes from the modules, not from the lesson bank: the
    // shelf reads in the order the learner meets them.
    lessons: [
      for (final module in modules)
        for (final lesson in module.lessons)
          (
            id: lesson.id,
            title: lesson.title,
            subtitle: 'Module ${module.n} · ${module.label}',
          ),
    ],
    guides: [
      for (final guide in (await guides).earned)
        (
          id: guide.subject,
          title: guide.title,
          subtitle: 'Visual guide · ${guide.label}',
        ),
    ],
  );
}
