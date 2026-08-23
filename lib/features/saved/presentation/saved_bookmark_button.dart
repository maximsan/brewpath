import 'package:brew_path/features/saved/domain/saved_providers.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The bookmark that puts one thing on the Saved shelf, and takes it off.
///
/// One control for all three saveable kinds — a lesson, a term, a guide —
/// because they differ only by their key. A second bookmark widget would be a
/// second place for "what does filled mean" to drift.
///
/// Its state is **announced, not just drawn**: `Semantics.toggled` is what a
/// screen reader reads, so saved-ness never rests on the icon alone.
class SavedBookmarkButton extends ConsumerWidget {
  /// Creates a [SavedBookmarkButton] for [savedKey].
  const SavedBookmarkButton({
    required this.savedKey,
    required this.label,
    super.key,
  });

  /// The prefixed key this bookmark writes — see `saved_key.dart`.
  final String savedKey;

  /// What the bookmark is *for*, said in full to a screen reader: the term or
  /// lesson title, so a page with more than one is not a row of "Save".
  final String label;

  Future<void> _toggle(WidgetRef ref) async {
    await toggleSaved(
      ref.read(snapshotRepositoryProvider),
      key: savedKey,
      now: DateTime.now(),
    );
    ref.invalidate(savedKeysProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // A read that has not resolved — or that failed — shows as not-saved
    // rather than as a spinner or an error: the bookmark is a control, and one
    // that flickers on every rebuild is worse than one that settles a frame
    // late. The cost is that a failed read looks like an empty shelf, which is
    // the right way round for a bookmark and the wrong way round for the shelf
    // itself, which surfaces its error.
    final isSaved = ref.watch(isKeySavedProvider(savedKey)).value ?? false;

    // `isSelected` rather than a wrapping `Semantics(toggled:)`: the button
    // builds its own semantics node, so an outer one does not merge into it
    // and the toggled state never reaches a screen reader. Letting the button
    // own the flag is the difference between announcing the state and only
    // drawing it.
    return IconButton(
      isSelected: isSaved,
      icon: const Icon(Icons.bookmark_outline),
      selectedIcon: const Icon(Icons.bookmark),
      color: context.mood.ink,
      style: IconButton.styleFrom(foregroundColor: context.mood.accent),
      tooltip: isSaved ? 'Remove $label from Saved' : 'Save $label',
      onPressed: () => _toggle(ref),
    );
  }
}
