import 'package:coffee_quest/shared/theme/app_colors.dart';
import 'package:coffee_quest/shared/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Text-only accent button (e.g. "Already have progress? Restore"). Mirrors
/// the `.btn-link` style from the design bundle.
class LinkButton extends StatelessWidget {
  const LinkButton({required this.label, required this.onPressed, super.key});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.darkRoastAccent,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(
        label,
        style: AppTypography.body(
          color: AppColors.darkRoastAccent,
        ).copyWith(decoration: TextDecoration.none),
      ),
    );
  }
}
