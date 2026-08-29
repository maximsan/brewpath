import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The surface every Profile card is drawn on: `surface` fill, `rule` hairline,
/// and a tap that covers the whole card.
///
/// The design makes each of these a `<button>` rather than a card with a row
/// inside it, so the whole thing is the target. Shared here because three cards
/// repeat it and a hairline that drifts on one of them is the kind of thing
/// only a screenshot catches.
///
/// **The radii live here, not on each card.** `AppRadii` ships one token and
/// says a component that needs its own may sit anywhere in 12–20 — "slack
/// around chrome rather than a set of stops of its own" — so these are not
/// tokens and not `OffTokens` either. Naming them once keeps the design's two
/// values one fact rather than three copies.
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

    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: semanticLabel != null,
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
