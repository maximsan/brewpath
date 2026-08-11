import 'package:brew_path/shared/theme/app_typography.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// Text-only accent button (e.g. "Already have progress? Restore"). Mirrors
/// the `.btn-link` style from the design bundle.
class LinkButton extends StatelessWidget {
  /// Creates a [LinkButton].
  const LinkButton({required this.label, required this.onPressed, super.key});

  /// Text shown on the button.
  final String label;

  /// Tap handler; `null` disables the button.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: mood.accent,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(
        label,
        style: AppTypography.body(
          mood,
          color: mood.accent,
        ).copyWith(decoration: TextDecoration.none),
      ),
    );
  }
}
