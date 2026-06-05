import 'package:coffee_quest/shared/theme/app_colors.dart';
import 'package:coffee_quest/shared/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Full-width, square-corner primary CTA used across onboarding. Mirrors the
/// `.btn-primary` style from the design bundle (2px corner radius, accent
/// fill, accent-ink text). When disabled, swaps to a muted neutral fill so
/// the affordance is still clearly visible against the dark-roast
/// background — the prototype's 35% opacity fade is invisible on screen.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final background = enabled
        ? AppColors.darkRoastAccent
        : AppColors.darkRoastSurface2;
    final foreground = enabled
        ? AppColors.darkRoastAccentInk
        : AppColors.darkRoastInkMute;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          disabledBackgroundColor: AppColors.darkRoastSurface2,
          disabledForegroundColor: AppColors.darkRoastInkMute,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(2)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Text(label, style: AppTypography.button(color: foreground)),
      ),
    );
  }
}
