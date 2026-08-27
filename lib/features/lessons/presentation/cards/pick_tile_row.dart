import 'package:brew_path/features/lessons/presentation/cards/card_tints.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/off_token.dart';
import 'package:flutter/material.dart';

/// How far the tile *not* picked recedes. It stays legible — the guess can
/// still be changed, so the other option is dimmed, never disabled.
const double _fadedOpacity = 0.62;

/// Vertical room inside a tile, which the design sets far taller than a row.
/// Off the spacing scale on purpose — see the register entry for why.
final double _tilePadding = OffTokens.pickTilePadding.value;

/// The two-up guess a `predict` card offers.
///
/// A row list would read as a list of answers. The design gives this moment
/// two tiles side by side, deliberately unlike every other picking card in the
/// course: it is the one choice that is **not** graded, and it should not look
/// like the ones that are.
///
/// The guess stays changeable until the learner moves on. Nothing is scored,
/// so there is nothing to protect by latching — and a first instinct the
/// learner immediately reconsiders is still the instinct the card wants.
class PickTileRow extends StatelessWidget {
  /// Creates a [PickTileRow].
  const PickTileRow({
    required this.options,
    required this.chosenIndex,
    required this.onChoose,
    super.key,
  });

  /// The guesses, already in display order.
  final List<String> options;

  /// The tile picked, or null while the learner has not guessed.
  final int? chosenIndex;

  /// Called with the display index of the tile tapped.
  final void Function(int index) onChoose;

  @override
  Widget build(BuildContext context) {
    // The design lays the tiles on a `1fr 1fr` grid, so they share a height
    // whichever option carries the longer word. A stretched Row alone cannot:
    // inside a scroll view its height is unbounded.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < options.length; index++) ...[
            if (index > 0) const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _PickTile(
                text: options[index],
                chosen: chosenIndex == index,
                faded: chosenIndex != null && chosenIndex != index,
                onTap: () => onChoose(index),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PickTile extends StatelessWidget {
  const _PickTile({
    required this.text,
    required this.chosen,
    required this.faded,
    required this.onTap,
  });

  final String text;
  final bool chosen;
  final bool faded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Opacity(
      opacity: faded ? _fadedOpacity : 1,
      child: Semantics(
        button: true,
        selected: chosen,
        label: text,
        excludeSemantics: true,
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            backgroundColor: chosen
                ? mood.accent.withValues(alpha: CardTints.wash)
                : null,
            padding: EdgeInsets.symmetric(
              vertical: _tilePadding,
              horizontal: AppSpacing.base,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.chrome),
            ),
            side: BorderSide(color: chosen ? mood.accent : mood.rule),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: AppText.heading(mood: mood),
          ),
        ),
      ),
    );
  }
}
