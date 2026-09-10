import 'package:brew_path/core/widgets/dashed_rounded_border.dart';
import 'package:brew_path/features/lessons/presentation/cards/match_line.dart';
import 'package:brew_path/features/lessons/presentation/cards/match_tile_state.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/off_token.dart';
import 'package:flutter/material.dart';

/// `.match-item.selected` is a hairline border plus an inset second line;
/// doubling the width is how that reads without painting two.
const double _doubledBorder = 2;
const double _hairline = 1;

/// One tile on a match board — a trait on the left, an answer on the right.
///
/// Both columns draw the same chrome, so it is one widget: what differs is
/// the [state] handed in and whether it is a drag source or a drop target,
/// which the board decides.
class MatchTile extends StatelessWidget {
  /// Creates a [MatchTile].
  const MatchTile({
    required this.text,
    required this.state,
    required this.semanticsLabel,
    this.onTap,
    this.dragging = false,
    this.align = TextAlign.start,
    super.key,
  });

  /// The trait or the answer itself.
  final String text;

  /// How the design marks it right now.
  final MatchTileState state;

  /// Everything the tile says aloud — the text, and what became of it.
  final String semanticsLabel;

  /// Selects or drops on this tile. Null once it is out of play.
  final VoidCallback? onTap;

  /// Whether this is the trait left behind while its clone is dragged.
  final bool dragging;

  /// The design sets the answers right, against the gutter the lines cross.
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final border = BorderSide(
      color: state.border(mood),
      width: state.isDoubled ? _doubledBorder : _hairline,
    );

    // The design's `border-style: dashed` on the tile a drag left behind. Its
    // own painter, because Flutter has no dashed `BorderSide`.
    final shape = dragging
        ? DashedRoundedBorder(radius: AppRadii.chrome, side: border)
        : RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.chrome),
            side: border,
          );

    return Semantics(
      button: onTap != null,
      selected: state == MatchTileState.held,
      label: semanticsLabel,
      excludeSemantics: true,
      child: Opacity(
        opacity: dragging ? OffTokens.matchDraggingOpacity.value : 1,
        child: Material(
          // `background: var(--bg)` on the tile left behind, so the dashes
          // read as a slot cut out of the page rather than as a card on it.
          color: dragging ? mood.bg : state.fill(mood) ?? mood.surface,
          shape: shape,
          // The design's own 150ms on this tile, rather than Material's 200:
          // reduced motion drops it, and the tile changes between frames.
          animationDuration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : matchTileTransition,
          child: InkWell(
            onTap: onTap,
            customBorder: shape,
            child: Padding(
              padding: OffTokens.matchTilePadding.value,
              child: Text(
                text,
                textAlign: align,
                style: AppText.support(color: mood.ink),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The clone that follows the pointer while a trait is dragged.
///
/// Its own widget rather than a [MatchTile] in a different state: the design
/// gives it a shadow and an accent outline no tile on the board wears, and it
/// is never in the tree at the same time as the tile it was cloned from.
class MatchDragGhost extends StatelessWidget {
  /// Creates a [MatchDragGhost] carrying [text].
  const MatchDragGhost({required this.text, required this.width, super.key});

  /// The trait being carried.
  final String text;

  /// The width of the tile it was lifted from, so it does not resize mid-drag.
  final double width;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: width,
        padding: OffTokens.matchTilePadding.value,
        decoration: BoxDecoration(
          color: mood.surface,
          borderRadius: BorderRadius.circular(AppRadii.chrome),
          border: Border.all(color: mood.accent, width: _doubledBorder),
          boxShadow: const [
            BoxShadow(
              // `0 10px 24px -8px rgba(0,0,0,0.35)`, the one shadow on the
              // board: the clone is the only thing off the page.
              color: Color(0x59000000),
              blurRadius: 24,
              spreadRadius: -8,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Text(text, style: AppText.support(color: mood.ink)),
      ),
    );
  }
}
