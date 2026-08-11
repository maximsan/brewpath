import 'package:brew_path/shared/theme/app_colors.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_typography.dart';
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
    final borderColor = selected
        ? AppColors.darkRoastAccent
        : AppColors.darkRoastRule;
    return Material(
      color: AppColors.darkRoastSurface,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.pickTitle()),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(description, style: AppTypography.bodySm()),
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
    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.darkRoastAccent : AppColors.darkRoastRule,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: _innerDotSize,
                height: _innerDotSize,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.darkRoastAccent,
                ),
              ),
            )
          : null,
    );
  }
}
