import 'package:brew_path/core/utils/module_icons.dart';
import 'package:brew_path/shared/models/module_model.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// Tinted hero at the top of the module screen: category icon + title +
/// description.
class ModuleHeroWidget extends StatelessWidget {
  /// Creates a [ModuleHeroWidget].
  const ModuleHeroWidget({required this.module, super.key});

  /// The module to summarise.
  final ModuleModel module;

  static const double _badgeSize = 56;
  static const double _iconSize = 28;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: _badgeSize,
          height: _badgeSize,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: mood.accent,
            borderRadius: BorderRadius.circular(AppRadii.chrome),
          ),
          child: Icon(
            moduleIcon(module.iconName),
            size: _iconSize,
            color: mood.accentInk,
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
                  color: mood.inkMute,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
