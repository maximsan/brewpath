import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/features/challenges/presentation/challenge_park_geometry.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The standing affordance: a double chevron pointing the way the card goes.
///
/// Directional, so it says *push me* rather than only *something is here*. A
/// child of the card rather than a sibling behind it, or the opaque card
/// paints over it.
class ChallengeParkChevron extends StatelessWidget {
  /// Creates a [ChallengeParkChevron] against the hint's state.
  const ChallengeParkChevron({
    required this.hinting,
    required this.used,
    super.key,
  });

  /// The design's `width: 15, height: 15` on the pair.
  static const double _mark = 15;

  /// The second chevron is drawn 4.6 right of the first in a 16-unit box.
  static const double _stride = _mark * 4.6 / 16;

  /// The design's `transition: opacity 260ms ease`.
  static const Duration _dim = Duration(milliseconds: 260);

  /// Whether the first-run hint is teaching the gesture right now.
  final bool hinting;

  /// Whether the gesture has been used before.
  final bool used;

  @override
  Widget build(BuildContext context) {
    final mark = IconMark(
      AppIcon.chevron,
      size: _mark,
      color: context.mood.accentText,
    );

    return ExcludeSemantics(
      child: AnimatedOpacity(
        opacity: challengeChevronOpacity(hinting: hinting, used: used),
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : _dim,
        curve: Curves.ease,
        child: SizedBox(
          width: _mark + _stride,
          height: _mark,
          child: Stack(
            children: [
              mark,
              Positioned(left: _stride, child: mark),
            ],
          ),
        ),
      ),
    );
  }
}
