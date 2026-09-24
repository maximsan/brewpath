import 'dart:async';

import 'package:brew_path/core/utils/module_icons.dart';
import 'package:brew_path/features/cards/domain/cards_grid.dart';
import 'package:brew_path/features/cards/presentation/card_art_mark.dart';
import 'package:brew_path/features/cards/presentation/card_challenge_corner.dart';
import 'package:brew_path/features/cards/presentation/card_sheet.dart';
import 'package:brew_path/features/cards/presentation/card_tint.dart';
import 'package:brew_path/features/challenges/domain/card_challenge_state.dart';
import 'package:brew_path/features/challenges/domain/challenge_providers.dart';
import 'package:brew_path/l10n/app_strings.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const double _tilePadding = AppSpacing.base;

/// The stamp the design drops in where a card has no art. A fixed size, not
/// the height of the slot: the art fills the row, a stand-in mark does not.
const double _fallbackMarkSize = 64;

/// How far a locked tile recedes, and how faint its two lines and its mark sit
/// within that.
const double _lockedOpacity = 0.32;
const double _lockedLineOpacity = 0.55;
const double _lockedMarkOpacity = 0.45;

/// One tile in the Cards grid.
///
/// Earned, it names its place in the set and wears its kind's wash; locked, it
/// recedes but still says which card it is, so a gap is a known one. The
/// design's `VISUAL GUIDE` line is not ported, because no collectible is of
/// that kind. The artwork is extracted rather than redrawn (#480).
class CardGridItemWidget extends ConsumerWidget {
  /// Creates a [CardGridItemWidget].
  const CardGridItemWidget({required this.placed, super.key});

  /// The card, where it sits in the catalogue, and how big the catalogue is.
  final PlacedCard placed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = placed.item;
    final mood = context.mood;
    final number = formatCardPlace(placed);

    if (!item.isCollected) {
      return Opacity(
        opacity: _lockedOpacity,
        child: _Tile(
          surface: mood.surface,
          // An em-dash where an earned card says CARD: the slot is spoken for,
          // and what it is is not.
          top: const _SubLine('—', opacity: _lockedLineOpacity),
          bottom: _SubLine(number, opacity: _lockedLineOpacity),
          child: const _UnknownMark(),
        ),
      );
    }

    final challenge =
        ref.watch(cardChallengeStateProvider(item.card.id)).asData?.value ??
        CardChallengeState.none;

    return _Tile(
      surface: cardTint(mood, item.card.kind),
      onTap: () => unawaited(showCardSheet(context, item)),
      corner: CardChallengeCorner.forState(challenge),
      top: _SubLine(context.strings.cardNumber(number)),
      bottom: Text(
        item.card.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: AppText.lead(mood: mood, face: AppFace.display),
      ),
      child: CardArtMark(
        kind: item.card.kind,
        fallback: moduleMark(item.card.iconName),
        fallbackSize: _fallbackMarkSize,
        fallbackColor: mood.accent,
      ),
    );
  }
}

/// The frame both branches share: a bordered card, its two lines pushed apart
/// with whatever it draws in between.
class _Tile extends StatelessWidget {
  const _Tile({
    required this.surface,
    required this.top,
    required this.bottom,
    required this.child,
    this.onTap,
    this.corner,
  });

  final Color surface;
  final Widget top;
  final Widget bottom;
  final Widget child;
  final VoidCallback? onTap;
  final Widget? corner;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Material(
      color: surface,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: mood.rule),
        borderRadius: BorderRadius.circular(AppRadii.chrome),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(_tilePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  top,
                  Expanded(child: Center(child: child)),
                  bottom,
                ],
              ),
            ),
            if (corner case final corner?)
              Positioned(
                top: AppSpacing.xs,
                right: AppSpacing.xs,
                child: corner,
              ),
          ],
        ),
      ),
    );
  }
}

/// `.cc-sub` — mono at the micro step, lettered wide and set in caps.
class _SubLine extends StatelessWidget {
  const _SubLine(this.text, {this.opacity = 1});

  final String text;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Text(
        text,
        style: AppText.micro(
          mood: context.mood,
          face: AppFace.mono,
          tracking: AppTracking.marker,
        ),
      ),
    );
  }
}

/// What a locked tile draws where an earned one draws its card.
///
/// A mono question mark, which is what the design actually renders:
/// `LockedSilhouette` branches on `'silhouette'` and `'dot'`, and a card's kind
/// is never either — every real collectible falls through to the `?`. The two
/// shapes above it are unreachable, so porting them would be porting dead code.
class _UnknownMark extends StatelessWidget {
  const _UnknownMark();

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Opacity(
      opacity: _lockedMarkOpacity,
      child: Text(
        '?',
        style: AppText.title(mood: mood, face: AppFace.mono),
      ),
    );
  }
}
