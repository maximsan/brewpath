import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The surface every Profile card is drawn on: `surface` fill, `rule` hairline,
/// and a tap that covers the whole card.
///
/// The design makes each of these a `<button>` rather than a card with a row
/// inside it, so the whole thing is the target. Shared here because four cards
/// repeat it and a hairline that drifts on one of them is the kind of thing
/// only a screenshot catches.
///
/// **Radius is per-card.** `AppRadii` ships one token and says a component that
/// needs its own may sit anywhere in 12–20 — "slack around chrome rather than
/// a set of stops of its own". The design uses 20 on the hero and 16 on the
/// rest, so each caller names its own within that slack.
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

  /// The design's padding on these cards.
  static const EdgeInsets defaultPadding = EdgeInsets.all(16);

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
