import 'package:brew_path/core/widgets/dashed_rounded_border.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The outline width every state keeps unless a kind asks for heavier.
const double _hairline = 1;

/// One tappable option row, in the shape every picking card draws them.
///
/// The frame only — border, fill, hit target and the spoken label. What the
/// row *contains* and what a mark *means* belong to the list that owns the
/// card's rule, which is why those arrive as a [child] and a colour rather
/// than as flags here.
class CardOptionTile extends StatelessWidget {
  /// Creates a [CardOptionTile].
  const CardOptionTile({
    required this.semanticsLabel,
    required this.child,
    this.onTap,
    this.borderColor,
    this.fillColor,
    this.borderWidth,
    this.dashed = false,
    super.key,
  });

  /// Everything the row says, already assembled — the option and its mark.
  final String semanticsLabel;

  /// The row's own content.
  final Widget child;

  /// Null once the card has latched, which is what disables the row.
  final VoidCallback? onTap;

  /// Set once the row carries a mark. The width never changes with it: the
  /// design keeps the outline hairline in every state and lets colour and
  /// tint carry the mark.
  final Color? borderColor;

  /// Fill behind a marked row, where the kind distinguishes marks by fill.
  final Color? fillColor;

  /// Width of the outline, where a kind reads one state heavier. Defaults to
  /// the hairline every other state keeps.
  final double? borderWidth;

  /// Whether the outline is drawn in dashes — the design's "should have been
  /// picked" state, which must never be mistakable for a row the learner got
  /// right.
  final bool dashed;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    final side = BorderSide(
      color: borderColor ?? mood.rule,
      width: borderWidth ?? _hairline,
    );

    return Semantics(
      button: true,
      enabled: onTap != null,
      label: semanticsLabel,
      excludeSemantics: true,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          alignment: Alignment.centerLeft,
          backgroundColor: fillColor,
          padding: const EdgeInsets.all(AppSpacing.md),
          // A dashed outline is painted by the shape, so the button's own
          // side must stand down or the two draw over each other.
          shape: dashed
              ? DashedRoundedBorder(radius: AppRadii.chrome, side: side)
              : RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.chrome),
                ),
          side: dashed ? BorderSide.none : side,
        ),
        child: child,
      ),
    );
  }
}
