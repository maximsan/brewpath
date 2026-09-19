import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The surface every Profile card is drawn on: `surface` fill, `rule` hairline,
/// and a tap that covers the whole card.
///
/// The design makes each of these a `<button>` rather than a card with a row
/// inside, so the whole thing is the target. The two radii are named here
/// because `AppRadii` leaves chrome slack in 12–20 rather than ship a stop.
class ProfileCard extends StatelessWidget {
  /// Creates a [ProfileCard].
  const ProfileCard({
    required this.radius,
    required this.child,
    this.onTap,
    this.semanticLabel,
    this.padding = defaultPadding,
    super.key,
  });

  /// The design's radius on the hero — the widest it uses, and the reason the
  /// hero reads as softer than the cards under it.
  static const double heroRadius = 20;

  /// The design's radius on every card below the hero.
  static const double cardRadius = 16;

  /// The design's padding on these cards.
  static const EdgeInsets defaultPadding = EdgeInsets.all(AppSpacing.md);

  /// The design's roomier padding on the two headline cards — 18, between
  /// `AppSpacing.md` and `lg` and belonging to neither.
  static const EdgeInsets headlinePadding = EdgeInsets.all(AppSpacing.md + 2);

  /// Corner radius, named by the caller from the design.
  final double radius;

  /// The card's content.
  final Widget child;

  /// Where the card leads, or null for a card that is not a control.
  final VoidCallback? onTap;

  /// What a screen reader announces instead of the card's own text, for a card
  /// whose parts read as a list rather than as one statement.
  final String? semanticLabel;

  /// Room inside the border.
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final shape = BorderRadius.circular(radius);

    final surface = DecoratedBox(
      decoration: BoxDecoration(
        color: mood.surface,
        border: Border.all(color: mood.rule),
        borderRadius: shape,
      ),
      child: Padding(padding: padding, child: child),
    );

    if (onTap == null) {
      return semanticLabel == null
          ? surface
          : Semantics(
              label: semanticLabel,
              excludeSemantics: true,
              child: surface,
            );
    }

    // Carried here only when the child's own tap is dropped with its text
    // (#487); beside a live InkWell it would split the card into two nodes.
    final announcesAlone = semanticLabel != null;

    return Semantics(
      button: true,
      label: semanticLabel,
      onTap: announcesAlone ? onTap : null,
      excludeSemantics: announcesAlone,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: shape,
          child: surface,
        ),
      ),
    );
  }
}
