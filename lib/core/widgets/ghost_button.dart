import 'package:brew_path/core/widgets/primary_button.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The full-width outlined CTA — the design's `.btn-ghost` in the accent.
///
/// **Quieter than the primary, louder than a link.** The design gives it to a
/// verdict that has an action attached: *Practice this lesson again* is the
/// screen's reading of a weak run and the way to act on it, which a text link
/// underplays and a second filled button would fight the way forward for.
///
/// Same height and radius as [PrimaryButton], because the two stack: a ghost
/// that sat at a different height would read as a different kind of control
/// rather than a quieter one.
class GhostButton extends StatelessWidget {
  /// Creates a [GhostButton].
  const GhostButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  /// Text shown on the button.
  final String label;

  /// Tap handler; `null` disables the button.
  final VoidCallback? onPressed;

  /// How much accent the border carries over the structural rule — the
  /// design's `color-mix(in oklab, var(--accent) 45%, var(--rule))`.
  static const double _borderTint = 0.45;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final enabled = onPressed != null;
    final foreground = enabled ? mood.accentText : mood.inkMute;

    return SizedBox(
      width: double.infinity,
      height: PrimaryButton.height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: foreground,
          disabledForegroundColor: mood.inkMute,
          side: BorderSide(
            color: enabled
                ? Color.alphaBlend(
                    mood.accent.withValues(alpha: _borderTint),
                    mood.rule,
                  )
                : mood.rule,
          ),
          // Its own shape for the same reason the primary carries one: this
          // renders in a themeless `MaterialApp`, where Material's default
          // would draw a pill.
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppRadii.chrome)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppRadii.chrome),
        ),
        child: Text(
          label,
          style: AppText.body(
            mood: mood,
            color: foreground,
            face: AppFace.control,
          ),
        ),
      ),
    );
  }
}
