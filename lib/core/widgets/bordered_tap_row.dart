import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// A surface on the ground, ruled and tappable: the frame the design's chips
/// and slim entry rows share.
///
/// Only the frame; what goes inside is the caller's. The chip and the row stay
/// separate components because the design draws them as two, but they must not
/// disagree about the surface, the rule and the corner, which live here.
class BorderedTapRow extends StatelessWidget {
  /// Creates a [BorderedTapRow].
  const BorderedTapRow({
    required this.semanticsLabel,
    required this.onTap,
    required this.padding,
    required this.child,
    super.key,
  });

  /// What a screen reader announces. The children are excluded, so this is the
  /// whole announcement rather than a preamble to one.
  final String semanticsLabel;

  /// What a press does.
  final VoidCallback onTap;

  /// Room inside the frame, which differs between a chip and a row.
  final EdgeInsets padding;

  /// The frame's contents.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Semantics(
      button: true,
      label: semanticsLabel,
      // The action, not just the flag: `excludeSemantics` drops the InkWell's
      // tap along with the text, and a node saying "button" with no tap to
      // carry announces something a screen reader cannot press (#487).
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        color: mood.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.chrome),
          side: BorderSide(color: mood.rule),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
