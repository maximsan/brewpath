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

  /// What the Studio door says under its title for [outfit]: the roast, and
  /// whatever else has actually been put on.
  ///
  /// Takes the outfit rather than reading [worn], because the door draws the
  /// *gated* one. Naming the plain bean's `none`s is skipped: a resting state
  /// is not a choice, and reading it back as one would say it was.
  String subtitleFor(CompanionConfig outfit) {
    final chosen = [
      _labelOf(options.roasts, outfit.roast),
      if (outfit.hat != CompanionConfig.initial.hat)
        _labelOf(options.hats, outfit.hat),
      if (outfit.gear != CompanionConfig.initial.gear)
        _labelOf(options.gear, outfit.gear),
      if (outfit.sprout != CompanionConfig.initial.sprout)
        _labelOf(options.sprouts, outfit.sprout),
    ].whereType<String>();
    return chosen.join(' · ');
  }

  /// The label the bank gives [id], or null when it ships no such option.
  static String? _labelOf(List<CompanionOption> axis, String id) =>
      axis.where((option) => option.id == id).firstOrNull?.label;
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
