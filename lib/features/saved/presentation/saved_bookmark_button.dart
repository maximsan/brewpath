import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/features/monetization/domain/course_entitlement.dart';
import 'package:brew_path/features/saved/domain/saved_cap.dart';
import 'package:brew_path/features/saved/domain/saved_providers.dart';
import 'package:brew_path/features/saved/domain/saved_shelf.dart';
import 'package:brew_path/features/saved/presentation/saved_gate.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The bookmark that puts one thing on the Saved shelf, and takes it off.
///
/// One control for all three saveable kinds — a lesson, a term, a guide —
/// because they differ only by their key. Its state is **announced, not just
/// drawn**: `Semantics.toggled` is what a screen reader reads, so saved-ness
/// never rests on the icon alone.
class SavedBookmarkButton extends ConsumerWidget {
  /// Creates a [SavedBookmarkButton] for [savedKey].
  const SavedBookmarkButton({
    required this.savedKey,
    required this.label,
    this.caption,
    this.ringed = false,
    super.key,
  });

  /// The design's mark beside a caption, smaller than the bare bookmark.
  static const double _captionedMark = 16;

  /// The top-bar ring: `borderRadius: 999, width: 32, height: 32` on a
  /// `1px solid var(--rule)` border, accent once saved, with the mark at 16.
  static const double _ringSize = 32;
  static const double _ringedMark = 16;

  /// The prefixed key this bookmark writes — see `saved_key.dart`.
  final String savedKey;

  /// What the bookmark is *for*, said in full to a screen reader: the term or
  /// lesson title, so a page with more than one is not a row of "Save".
  final String label;

  /// Words beside the mark, in the one place the design writes them: the
  /// guide inside a lesson, where there is room to invite the save and to say
  /// where it went. Every other host draws the mark alone.
  final ({String saved, String unsaved})? caption;

  /// Whether this sits in a top bar, where the design's settled bookmark
  /// style is a ring: muted ink on a rule-coloured ring, accent once saved.
  final bool ringed;

  Future<void> _toggle(BuildContext context, WidgetRef ref) async {
    // **Awaited, not read for its current value.** Nothing watches the
    // entitlement here, so a synchronous read is still unresolved on the first
    // tap and would report `false` — refusing a paying learner at five items.
    final isPlus = await ref.read(courseEntitlementProvider.future);
    // The cap is judged on what the shelf would show, so the number the
    // learner is refused at is the number they were told they had.
    final visible = savedShelfCount(await ref.read(savedShelfProvider.future));

    final outcome = await toggleSaved(
      ref.read(snapshotRepositoryProvider),
      key: savedKey,
      now: DateTime.now(),
      isPlus: isPlus,
      visible: visible,
    );

    if (outcome is SaveGateRaised) {
      if (context.mounted) showSavedCapReached(context);
      // Nothing moved, so nothing to re-read.
      return;
    }
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

    if (caption case final caption?) {
      return _Captioned(
        isSaved: isSaved,
        caption: caption,
        label: label,
        onPressed: () => _toggle(context, ref),
      );
    }

    // `isSelected` rather than a wrapping `Semantics(toggled:)`: the button
    // builds its own semantics node, so an outer one does not merge into it
    // and the toggled state never reaches a screen reader. Letting the button
    // own the flag is the difference between announcing the state and only
    // drawing it.
    final mood = context.mood;
    final markSize = ringed ? _ringedMark : null;
    return IconButton(
      isSelected: isSaved,
      // One mark, two states. The design's rule for it is "filled accent when
      // saved" — so the saved state is the same drawing filled, not a second
      // glyph, which is why both slots name the same mark.
      icon: IconMark(AppIcon.bookmark, size: markSize),
      selectedIcon: IconMark(AppIcon.bookmark, active: true, size: markSize),
      // One colour source. Setting both `color` and a `styleFrom`
      // foreground silently drops one of them in the button's style merge,
      // which is how the saved and unsaved states ended up the same colour.
      style: ringed
          ? IconButton.styleFrom(
              foregroundColor: isSaved ? mood.accent : mood.inkMute,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.pill),
                side: BorderSide(color: isSaved ? mood.accent : mood.rule),
              ),
              padding: EdgeInsets.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            )
          : IconButton.styleFrom(
              foregroundColor: isSaved ? mood.accent : mood.ink,
            ),
      constraints: ringed
          ? const BoxConstraints.tightFor(width: _ringSize, height: _ringSize)
          : null,
      tooltip: isSaved ? 'Remove $label from Saved' : 'Save $label',
      onPressed: () => _toggle(context, ref),
    );
  }
}

/// The bookmark with words beside it — the design's save control on a guide
/// inside a lesson. A text button rather than an icon one, because the words
/// are half the target.
class _Captioned extends StatelessWidget {
  const _Captioned({
    required this.isSaved,
    required this.caption,
    required this.label,
    required this.onPressed,
  });

  final bool isSaved;
  final ({String saved, String unsaved}) caption;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final tone = isSaved ? mood.accent : mood.inkMute;
    final words = isSaved ? caption.saved : caption.unsaved;

    return Semantics(
      button: true,
      toggled: isSaved,
      label: isSaved ? 'Remove $label from Saved' : 'Save $label',
      excludeSemantics: true,
      child: TextButton.icon(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          foregroundColor: tone,
          visualDensity: VisualDensity.compact,
        ),
        icon: IconMark(
          AppIcon.bookmark,
          active: isSaved,
          size: SavedBookmarkButton._captionedMark,
          color: tone,
        ),
        label: Text(
          words.toUpperCase(),
          style: AppText.label(face: AppFace.mono, color: tone),
        ),
      ),
    );
  }
}
