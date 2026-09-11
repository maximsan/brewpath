import 'package:brew_path/shared/models/content/companion_option.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:brew_path/shared/storage/snapshot/snapshot_values.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'roasty_studio_providers.g.dart';

/// Everything the wardrobe needs, resolved once.
///
/// `StudioGrove`'s twin: the four banks and what Roasty has on arrive together
/// because the screen cannot draw a single row without all of them.
@immutable
class RoastyStudio {
  /// Creates a [RoastyStudio].
  const RoastyStudio({required this.options, required this.worn});

  /// The four axes, in the order the banks ship them.
  final CompanionOptions options;

  /// What Roasty has on right now — what the confirm is compared against.
  final CompanionConfig worn;
}

/// The wardrobe's data: the four banks and the outfit Roasty has on.
///
/// Reads the snapshot rather than `companionOutfit`, deliberately: this is the
/// screen that *edits* the outfit, so it must see what is stored even while
/// the gate would hide it — the door that opens it is already Plus-locked.
@riverpod
Future<RoastyStudio> roastyStudio(Ref ref) async {
  final content = ref.watch(contentRepositoryProvider);
  final snapshot = await ref.watch(snapshotRepositoryProvider).read();

  return RoastyStudio(
    options: await content.getCompanionOptions(),
    worn: snapshot.clearedByDeleteOnly.companion.value,
  );
}
