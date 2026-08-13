import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_typography.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// Bordered selectable tile used on the onboarding goal + brewer screens.
/// Mirrors the `.pick-card` pattern from the design bundle: title + desc on
/// the left, a circular indicator on the right that fills when selected.
class PickCard extends StatelessWidget {
  /// Creates a [PickCard].
  const PickCard({
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
    super.key,
  });

  /// Card title (the option name).
  final String title;

  /// Supporting description shown under the title.
  final String description;

  /// Whether this card is the current selection.
  final bool selected;

  /// Called when the card is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final borderColor = selected ? mood.accent : mood.rule;
    return Material(
      color: mood.surface,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(AppRadii.editorial),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.pickTitle(mood)),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(description, style: AppTypography.bodySm(mood)),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _PickIndicator(selected: selected),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickIndicator extends StatelessWidget {
  const _PickIndicator({required this.selected});

  static const double _size = 28;
  static const double _innerDotSize = 14;

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: selected ? mood.accent : mood.rule),
      ),
      child: selected
          ? Center(
              child: Container(
                width: _innerDotSize,
                height: _innerDotSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: mood.accent,
                ),
              ),
            )
          : null,
    );
  }
}
