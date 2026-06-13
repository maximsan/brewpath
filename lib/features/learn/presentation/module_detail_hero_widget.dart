import 'package:coffee_quest/core/utils/module_icons.dart';
import 'package:coffee_quest/shared/models/module_model.dart';
import 'package:flutter/material.dart';

/// Tinted hero at the top of the module screen: category icon + title +
/// description.
class ModuleHeroWidget extends StatelessWidget {
  /// Creates a [ModuleHeroWidget].
  const ModuleHeroWidget({required this.module, super.key});

  /// The module to summarise.
  final ModuleModel module;

  static const double _badgeSize = 56;
  static const double _badgeRadius = 14;
  static const double _iconSize = 28;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: _badgeSize,
          height: _badgeSize,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(_badgeRadius),
          ),
          child: Icon(
            moduleIcon(module.iconName),
            size: _iconSize,
            color: colors.onPrimaryContainer,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                module.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                module.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
