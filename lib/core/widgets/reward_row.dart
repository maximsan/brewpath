import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// One occasional beat on a reward screen: what happened, and a quiet line
/// saying what it means.
///
/// **The one anatomy for every reward-list row** — a label, a muted detail,
/// and at most one trailing affordance. The freeze earn, a new card and the
/// Coffee Challenge offer are all this shape, which is what makes them read as
/// one list rather than three unrelated announcements.
///
/// Deliberately plain: no well, no accent kicker, no card of its own. The
/// screen already carries the celebration; a row that decorated itself would
/// compete with the tree above it.
class RewardRow extends StatelessWidget {
  /// Creates a [RewardRow].
  const RewardRow({
    required this.label,
    this.detail,
    this.onPress,
    super.key,
  });

  /// What happened — `Freeze earned`, `New card`.
  final String label;

  /// The quiet line under it. A row can stand without one.
  final String? detail;

  /// What the row opens onto, for the rows that open onto something. The row
  /// itself is the button; the circle is only its mark.
  final VoidCallback? onPress;

  /// The design's `38px` go-button.
  static const double _goSize = 38;

  /// And the arrow inside it.
  static const double _goMark = 16;

  /// The design tightens a row's vertical padding when it carries a go-button,
  /// so the taller control does not make its row deeper than its neighbours.
  static const double _padding = AppSpacing.sm;
  static const double _paddingWithGo = 10;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final detail = this.detail;
    final onPress = this.onPress;

    final row = Padding(
      padding: EdgeInsets.symmetric(
        vertical: onPress == null ? _padding : _paddingWithGo,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppText.support(mood: mood, color: mood.ink),
                ),
                if (detail != null) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    detail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.support(mood: mood),
                  ),
                ],
              ],
            ),
          ),
          if (onPress != null) ...[
            const SizedBox(width: AppSpacing.sm),
            const _GoMark(size: _goSize, mark: _goMark),
          ],
        ],
      ),
    );

    if (onPress == null) {
      return Semantics(
        label: detail == null ? label : '$label. $detail',
        excludeSemantics: true,
        child: row,
      );
    }
    return Semantics(
      button: true,
      label: detail == null ? label : '$label. $detail',
      excludeSemantics: true,
      child: InkWell(onTap: onPress, child: row),
    );
  }
}

/// The filled circle on an actionable row — the same affordance the challenge
/// offer wears, so every row that opens onto something says so the same way.
class _GoMark extends StatelessWidget {
  const _GoMark({required this.size, required this.mark});

  final double size;
  final double mark;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: mood.accent,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: IconMark(AppIcon.arrow, size: mark, color: mood.accentInk),
    );
  }
}

/// The reward list: occasional beats stacked, with a hairline **between** rows
/// and nowhere else.
///
/// No border and no fill — the design rules the list open (`.rw-li + .rw-li`
/// draws the only line there is), so a list of one row shows no chrome at all
/// and a screen that paid nothing shows nothing.
class RewardList extends StatelessWidget {
  /// Creates a [RewardList].
  const RewardList({required this.rows, super.key});

  /// The beats to show, in the order the design lists them. Empty draws
  /// nothing — not an empty box.
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();
    final mood = context.mood;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < rows.length; index++) ...[
          if (index > 0) Divider(height: 1, thickness: 1, color: mood.rule),
          rows[index],
        ],
      ],
    );
  }
}
