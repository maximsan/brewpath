import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/icons/replay_mark.dart';
import 'package:brew_path/features/monetization/domain/locked_row_copy.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/off_token.dart';
import 'package:flutter/material.dart';

/// One row of the practice shelf: what it drills, its name, what it costs or
/// takes, and the replay mark — or a lock.
///
/// **The row is not a card.** The design draws `.tap-row` flat on the page,
/// with a press highlight and nothing else around it; the shelf reads as one
/// list, not as a stack of boxes. The highlight bleeds a stop past the text
/// on each side (`margin: 0 -8px; padding: 12px 8px`), which is why the shelf
/// sits that stop inside the page gutter and every row pads it back.
///
/// Every practice list draws this one row — a finished lesson, a dictionary
/// drill, a mini-game — with an [icon] only where the design gives the kind
/// one: the lessons and the two drills. A game's kind is on its group's
/// heading, never repeated per row.
class ReplayRow extends StatelessWidget {
  /// Creates a [ReplayRow].
  const ReplayRow({
    required this.title,
    required this.sub,
    required this.onTap,
    this.icon,
    this.meta,
    this.locked = false,
    this.hint,
    super.key,
  });

  /// What a screen reader is told the tap does, when the label alone would
  /// not say — a locked game's *Shows the module that teaches it*. Being told
  /// only that a row is locked gives no reason to try it.
  final String? hint;

  /// The row's name — a lesson's title, a game's name.
  final String title;

  /// The eyebrow over the name: which module, or what the game drills.
  final String sub;

  /// The right-hand line: a duration, `Free`, or nothing for a locked row.
  final String? meta;

  /// Whether the row is behind the purchase, which swaps the replay mark for a
  /// lock and says so to a screen reader.
  final bool locked;

  /// What the row does. A locked row still taps — into the offer.
  final VoidCallback onTap;

  /// The kind glyph in the row's first column, where the design draws one.
  final Widget? icon;

  /// The design's `minHeight: 44` — a comfortable tap target.
  static const double _minHeight = 44;

  /// The design's first grid column, `24px`, for the kind glyph.
  static const double _iconColumn = 24;

  /// The design's replay mark, `width="18"`.
  static const double _markSize = 18;

  /// The design's `<LockMark size={13}/>` on a locked row.
  static const double _lockSize = 13;

  /// The design's `color-mix(in oklab, var(--ink-mute) 76%, var(--ink))` on
  /// the eyebrow and the meta line.
  static const double _inkShare = 0.76;

  /// The design's `marginTop: 2` between the eyebrow and the name.
  static const double _titleGap = 2;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final metaInk = mood.inkMix(_inkShare);
    final meta = this.meta;
    final icon = this.icon;

    return Semantics(
      button: true,
      label: _announcement,
      hint: hint,
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        sub.toUpperCase(),
                        style: AppText.label(
                          mood: mood,
                          face: AppFace.mono,
                          color: metaInk,
                        ),
                      ),
                      const SizedBox(height: _titleGap),
                      Text(
                        title,
                        style: AppText.support(
                          mood: mood,
                          face: AppFace.control,
                          color: mood.ink,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.base),
                if (meta != null) ...[
                  Text(
                    meta.toUpperCase(),
                    textAlign: TextAlign.right,
                    style: AppText.label(
                      mood: mood,
                      face: AppFace.mono,
                      color: metaInk,
                      tracking: AppTracking.hint,
                    ),
                  ),
                  SizedBox(width: OffTokens.practiceInlineGap.value),
                ],
                if (locked)
                  IconMark(AppIcon.lock, size: _lockSize, color: mood.inkMute)
                else
                  ReplayMark(size: _markSize, color: mood.inkMute),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// The design's `aria-label`: the three lines as one sentence, then what
  /// the tap does.
  String get _announcement {
    final lines = [title, sub, ?meta].join('. ');
    return locked
        ? '$lines. ${LockedRowCopy.partOfFoundations}.'
        : '$lines. Replay.';
  }
}
