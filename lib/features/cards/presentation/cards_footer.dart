import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/widgets/dashed_rounded_border.dart';
import 'package:brew_path/core/widgets/icon_badge.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/off_token.dart';
import 'package:flutter/material.dart';

/// What the block says under its count.
const String _invitation = 'Finish lessons to reveal new cards.';

/// The lock well's drawn size and its glyph, from the design source.
const double _lockWell = 40;
const double _lockGlyph = 20;

/// Radius of that well — its own, and deliberately not [AppRadii.chrome]: the
/// design draws it at 12, inside the slack the chrome language allows.
const double _lockWellRadius = 12;

/// How far the block's fill is pulled from the page toward a raised surface.
///
/// The design writes it as `color-mix(in oklab, var(--surface) 55%, var(--bg))`
/// — a surface that has not quite lifted off the page, which is the point: the
/// block stands for cards that are not there.
///
/// ⚠️ **Mixed in sRGB, not oklab.** `Color.lerp` is the only blend Flutter
/// gives us and it interpolates in sRGB, so the result is a shade off what the
/// design computes. Between two near-neutral surfaces the two spaces barely
/// part company; recorded because the ratio is transcribed exactly and the
/// space it is mixed in is not.
const double _blockLift = 0.55;

/// The remainder the grid does not draw, named under it.
///
/// Dashed rather than solid, because the block stands for an absence rather
/// than a surface. It is not tappable and carries no action: it says what is
/// left, and the way to move it is to finish a lesson.
///
/// **The count includes the teaser above it**, which reads as an off-by-one
/// and is not — see `cards_grid.dart`.
class CardsFooter extends StatelessWidget {
  /// Creates a [CardsFooter].
  const CardsFooter({required this.remaining, super.key});

  /// How many cards are still uncollected.
  final int remaining;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final count = '$remaining more to collect';

    return Semantics(
      label: '$count. $_invitation',
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: Color.lerp(mood.bg, mood.surface, _blockLift),
          shape: DashedRoundedBorder(
            radius: AppRadii.chrome,
            side: BorderSide(color: mood.rule),
          ),
        ),
        child: Padding(
          padding: OffTokens.cardsFooterPadding.value,
          child: Row(
            spacing: AppSpacing.base,
            children: [
              _lock(mood),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      count,
                      style: AppText.body(mood: mood, face: AppFace.control),
                    ),
                    SizedBox(height: OffTokens.cardsFooterLineGap.value),
                    Text(_invitation, style: AppText.support(mood: mood)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// The well the lock sits in — outlined, because it stands for a slot that
  /// is waiting rather than a chip that is filled.
  Widget _lock(MoodColors mood) => IconBadge.roundedMark(
    mark: AppIcon.lock,
    size: _lockWell,
    radius: _lockWellRadius,
    iconSize: _lockGlyph,
    background: mood.bg,
    foreground: mood.inkMute,
    borderColor: mood.rule,
  );
}
