import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/features/challenges/presentation/challenge_park_geometry.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
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

/// The gesture's keyboard and assistive-technology equivalent.
///
/// Collapsed to a hairline until it takes focus, so the card keeps no standing
/// control while staying operable without a pointer. Never `Offstage` and
/// never excluded from semantics: it is the only announced way to park.
class ChallengeParkButton extends StatefulWidget {
  /// Creates a [ChallengeParkButton] that calls [onPark].
  const ChallengeParkButton({required this.onPark, super.key});

  /// The design's own words on it.
  static const String label = 'Save for later';

  /// The design's `height: kbd ? 40 : 1`.
  static const double _open = 40;
  static const double _shut = 1;

  /// Called when the learner parks the challenge from here.
  final VoidCallback onPark;

  @override
  State<ChallengeParkButton> createState() => _ChallengeParkButtonState();
}

class _ChallengeParkButtonState extends State<ChallengeParkButton> {
  bool _hasFocus = false;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Padding(
      padding: EdgeInsets.only(top: _hasFocus ? AppSpacing.xs : 0),
      child: SizedBox(
        height: _hasFocus
            ? ChallengeParkButton._open
            : ChallengeParkButton._shut,
        width: double.infinity,
        child: Opacity(
          opacity: _hasFocus ? 1 : 0,
          child: OutlinedButton(
            onFocusChange: (value) => setState(() => _hasFocus = value),
            onPressed: widget.onPark,
            style: OutlinedButton.styleFrom(
              foregroundColor: mood.accentText,
              padding: EdgeInsets.zero,
              side: BorderSide(
                color: Color.lerp(mood.rule, mood.accent, _sideShare)!,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
            ),
            child: Text(
              ChallengeParkButton.label,
              style: AppText.support(color: mood.accentText),
            ),
          ),
        ),
      ),
    );
  }

  /// The design's `color-mix(in oklab, var(--accent) 30%, var(--rule))`.
  static const double _sideShare = 0.30;
}
