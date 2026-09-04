import 'package:brew_path/core/widgets/primary_button.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The full-width secondary CTA — the design's `.btn-ghost`: transparent, a
/// 1px `--rule` hairline, `--ink` text.
///
/// The design gives it one job: *"the second action in any bottom stack —
/// dismiss, skip, back"*, and it is emphatic that the job is not a link's —
/// *"a dismiss sitting under a primary (Not now, Maybe later, Back to Path) is
/// a ghost, never a bare link"*. So this is a component rather than a styled
/// `OutlinedButton` at each call site: the theme gives a bare outlined button
/// the right radius and nothing else, which is how the pair would drift.
///
/// It matches [PrimaryButton] in width and height on purpose — the two stack,
/// and a shorter second button reads as a different kind of control.
///
/// Disabled swaps the label to muted ink rather than taking the design's
/// `opacity: 0.35`, for the reason [PrimaryButton] gives: the fade is
/// invisible against the dark-roast background.
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

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final foreground = onPressed == null ? mood.inkMute : mood.ink;
    return SizedBox(
      width: double.infinity,
      height: PrimaryButton.height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          // `background: transparent` — the page shows through, which is what
          // separates a ghost from the recessed fill a disabled primary takes.
          backgroundColor: Colors.transparent,
          foregroundColor: foreground,
          disabledForegroundColor: mood.inkMute,
          side: BorderSide(color: mood.rule),
          // Declared here as well as on `AppTheme`, for the reason
          // `PrimaryButton` documents: `context.mood` falls back to Dark Roast
          // in a themeless `MaterialApp`, where an unshaped button is a pill.
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppRadii.chrome)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
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
