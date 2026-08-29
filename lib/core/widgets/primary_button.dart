import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// Full-width, square-corner primary CTA used across onboarding. Mirrors the
/// `.btn-primary` style from the design bundle (2px corner radius, accent
/// fill, accent-ink text). When disabled, swaps to a muted neutral fill so
/// the affordance is still clearly visible against the dark-roast
/// background — the prototype's 35% opacity fade is invisible on screen.
class PrimaryButton extends StatelessWidget {
  /// Creates a [PrimaryButton].
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  /// The design's fixed CTA height. Public because the sticky action bar
  /// reserves room for a button before one has been laid out, and a second
  /// copy of the number is a second thing to keep in step.
  static const double height = 52;

  /// Text shown on the button.
  final String label;

  /// Tap handler; `null` disables the button.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final enabled = onPressed != null;
    final background = enabled ? mood.accent : mood.surface2;
    final foreground = enabled ? mood.accentInk : mood.inkMute;
    return SizedBox(
      width: double.infinity,
      height: height,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          disabledBackgroundColor: mood.surface2,
          disabledForegroundColor: mood.inkMute,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppRadii.editorial)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
