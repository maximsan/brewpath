import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/icons/replay_mark.dart';
import 'package:brew_path/features/monetization/domain/locked_row_copy.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// One row of the practice list: its name, an eyebrow where the row has one,
/// and the mark that says what a tap does — replay arrow, chevron, or lock.
///
/// Flat on the page, not a card: its press highlight bleeds a stop past the
/// text (`margin: 0 -8px; padding: 12px 8px`), so the list sits that stop
/// inside the page gutter and every row pads it back.
class ReplayRow extends StatelessWidget {
  /// Creates a [ReplayRow].
  const ReplayRow({
    required this.title,
    required this.onTap,
    this.sub,
    this.icon,
    this.locked = false,
    this.starts = false,
    this.hint,
    super.key,
  });

  /// What a screen reader is told the tap does, when the label alone would
  /// not say — a locked game's *Shows the module that teaches it*. Being told
  /// only that a row is locked gives no reason to try it.
  final String? hint;

  /// The row's name — a lesson's title, a game's name.
  final String title;

  /// The eyebrow over the name — what a game drills, where a drill draws
  /// from. A lesson row has none: its sub-group's header carries the module.
  final String? sub;

  /// Whether the row is behind the purchase, which swaps the mark for a lock
  /// and says so to a screen reader.
  final bool locked;

  /// Whether the tap starts something rather than replaying it, which ends
  /// the row in a chevron and reads *Play* instead of *Replay*.
  final bool starts;

  /// What the row does. A locked row still taps — into the offer.
  final VoidCallback onTap;

  /// The kind glyph in the row's first column, where the design draws one.
  final Widget? icon;

  /// The design's `minHeight: 44` — a comfortable tap target.
  static const double _minHeight = 44;

  /// The design's first grid column, `20px`, for the kind glyph.
  static const double _iconColumn = 20;

  /// The design's replay mark, `width="18"`.
  static const double _markSize = 18;

  /// The design's `<LockMark size={13}/>` on a locked row.
  static const double _lockSize = 13;

  /// The design's `color-mix(in oklab, var(--ink-mute) 76%, var(--ink))` on
  /// the eyebrow.
  static const double _inkShare = 0.76;

  /// The design's `marginTop: 2` between the eyebrow and the name.
  static const double _titleGap = 2;

  /// What the tap does, for a screen reader.
  static const String _playsAnnouncement = 'Play';
  static const String _replaysAnnouncement = 'Replay';

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final icon = this.icon;

    return Semantics(
      button: true,
      label: _announcement,
      hint: hint,
      onTap: onTap,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.inner),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: _minHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.sm,
              horizontal: AppSpacing.xs,
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  SizedBox(
                    width: _iconColumn,
                    child: Center(child: icon),
                  ),
                  const SizedBox(width: AppSpacing.base),
                ],
                Expanded(child: _lines(mood)),
                const SizedBox(width: AppSpacing.base),
                _mark(mood),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// The eyebrow, where there is one, over the name.
  Widget _lines(MoodColors mood) {
    final sub = this.sub;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (sub != null) ...[
          Text(
            sub.toUpperCase(),
            style: AppText.label(
              mood: mood,
              face: AppFace.mono,
              color: mood.inkMix(_inkShare),
            ),
          ),
          const SizedBox(height: _titleGap),
        ],
        Text(
          title,
          style: AppText.support(
            mood: mood,
            face: AppFace.control,
            color: mood.ink,
          ),
        ),
      ],
    );
  }

  /// The trailing mark: a lock, a chevron, or the replay arrow.
  Widget _mark(MoodColors mood) {
    if (locked) {
      return IconMark(AppIcon.lock, size: _lockSize, color: mood.inkMute);
    }
    if (starts) return IconMark(AppIcon.chevron, color: mood.inkMute);
    return ReplayMark(size: _markSize, color: mood.inkMute);
  }

  /// The design's `aria-label`: the lines as one sentence, then what the tap
  /// does.
  String get _announcement {
    final lines = [title, ?sub].join('. ');
    if (locked) return '$lines. ${LockedRowCopy.partOfFoundations}.';
    return '$lines. ${starts ? _playsAnnouncement : _replaysAnnouncement}.';
  }
}
