import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/features/cards/presentation/card_art_mark.dart';
import 'package:brew_path/features/cards/presentation/card_tint.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The well's height, and how far past it the drawing is pushed.
///
/// The design draws a full-width band `height: 150` washed in the kind's tint,
/// and scales the art inside it to `1.15` so the drawing runs to the edges
/// rather than sitting in the middle of a box — which is why the band clips.
const double _wellHeight = 150;
const double _artScale = 1.15;

/// A card's drawing, in the tinted band the design sets it in.
///
/// The band takes the same wash as the card's tile, so a card opened from the
/// grid keeps the colour it was tapped on.
class CardArtWell extends StatelessWidget {
  /// Draws the art for [kind], falling back to [fallback] where there is none.
  const CardArtWell({
    required this.kind,
    required this.fallback,
    this.semanticLabel,
    super.key,
  });

  /// The collectible kind, as the content bank names it.
  final String kind;

  /// The mark to draw when the design has drawn no art for [kind].
  final AppIcon fallback;

  /// Read out in place of the drawing.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.editorial),
      child: ColoredBox(
        color: cardTint(context.mood, kind),
        child: SizedBox(
          height: _wellHeight,
          width: double.infinity,
          child: Center(
            child: Transform.scale(
              scale: _artScale,
              child: CardArtMark(
                kind: kind,
                fallback: fallback,
                size: _wellHeight,
                semanticLabel: semanticLabel,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
