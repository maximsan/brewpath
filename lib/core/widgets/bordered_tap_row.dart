import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// A surface on the ground, ruled and tappable: the frame the design's chips
/// and slim entry rows share.
///
/// Only the frame. What goes inside is the caller's — a chip pairs a name with
/// a count, a row pairs a name with a chevron — and the shapes stay separate
/// components because the design draws them as two. What they must not do is
/// disagree about the surface, the rule and the corner they sit on, which is
/// the part that lives here.
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
