import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/features/tour/domain/micro_tip.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/off_token.dart';
import 'package:flutter/material.dart';

/// One micro-tip, as the learner sees it: a small card at the foot of the
/// screen with an eyebrow, a claim, the rule behind it, and a way out.
///
/// Positioned by `MicroTipHost`; this is only the card. It announces itself as
/// a status so a screen reader reads the whole tip when it arrives rather than
/// leaving it to be found by touch.
class MicroTipCard extends StatelessWidget {
  /// Creates the card for [tip].
  const MicroTipCard({required this.tip, required this.onDismiss, super.key});

  /// The tip on show.
  final MicroTip tip;

  /// Hides the card. The tip is already recorded as seen by the time this can
  /// be pressed — the X closes it, it does not spend it.
  final VoidCallback onDismiss;

  /// The design's `0 14px 34px rgba(0,0,0,0.2)`: the card floats over the
  /// screen rather than sitting in it, which is what tells the learner it is
  /// not part of the page they were reading.
  static const List<BoxShadow> _lift = [
    BoxShadow(color: Color(0x33000000), blurRadius: 34, offset: Offset(0, 14)),
  ];

  /// How much accent the border carries — the design's
  /// `color-mix(in oklab, accent 30%, rule)`.
  static const double _borderAccent = 0.30;

  static const _padding = EdgeInsets.symmetric(
    vertical: AppSpacing.base,
    horizontal: AppSpacing.md,
  );

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    return Semantics(
      container: true,
      liveRegion: true,
      label: tip.announcement,
      // The card draws above the navigator, so it brings its own `Material`:
      // the ink under the X and the default text style the copy is set against
      // both come from one otherwise.
      child: Material(
        type: MaterialType.transparency,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: mood.surface,
            borderRadius: BorderRadius.circular(AppRadii.chrome),
            border: Border.all(
              color: Color.alphaBlend(
                mood.accent.withValues(alpha: _borderAccent),
                mood.rule,
              ),
            ),
            boxShadow: _lift,
          ),
          child: Padding(
            padding: _padding,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ExcludeSemantics(child: _Copy(tip: tip)),
                ),
                const SizedBox(width: AppSpacing.sm),
                _DismissButton(onPressed: onDismiss),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The X, labelled for assistive technology rather than tooltipped: a
/// `Tooltip` floats in an `Overlay`, and the card draws above the one the
/// navigator owns.
class _DismissButton extends StatelessWidget {
  const _DismissButton({required this.onPressed});

  /// The label the design gives the control, and the only name it has.
  static const String label = 'Dismiss';

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => MergeSemantics(
    child: Semantics(
      label: label,
      child: IconButton(
        icon: const IconMark(AppIcon.close),
        iconSize: AppSpacing.md,
        color: context.mood.inkMute,
        onPressed: onPressed,
      ),
    ),
  );
}

/// The card's three lines, at the sizes the design sets them.
class _Copy extends StatelessWidget {
  const _Copy({required this.tip});

  final MicroTip tip;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SmallcapsLabel(tip.eyebrow, color: mood.accentText),
        SizedBox(height: OffTokens.microTipEyebrowGap.value),
        Text(
          tip.title,
          style: AppText.support(color: mood.ink, face: AppFace.control),
        ),
        SizedBox(height: OffTokens.microTipTitleGap.value),
        // Prose set at the label step, so it takes neither that step's
        // smallcaps tracking nor its heading leading.
        Text(
          tip.body,
          style: AppText.label(mood: mood).copyWith(
            letterSpacing: OffTokens.microTipBodyTracking.value,
            height: OffTokens.microTipBodyLeading.value,
          ),
        ),
      ],
    );
  }
}
