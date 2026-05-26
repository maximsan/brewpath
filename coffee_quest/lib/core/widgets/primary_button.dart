import 'package:flutter/material.dart';

import 'package:coffee_quest/shared/theme/app_colors.dart';
import 'package:coffee_quest/shared/theme/app_typography.dart';

/// Full-width, square-corner primary CTA used across onboarding. Mirrors the
/// `.btn-primary` style from the design bundle (2px corner radius, accent
/// fill, accent-ink text, 35% opacity disabled state).
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
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.35,
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.darkRoastAccent,
            foregroundColor: AppColors.darkRoastAccentInk,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(2)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          child: Text(
            label,
            style: AppTypography.button(color: AppColors.darkRoastAccentInk),
          ),
        ),
      ),
    );
  }
}
