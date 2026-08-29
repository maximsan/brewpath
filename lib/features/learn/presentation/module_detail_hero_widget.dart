import 'package:brew_path/core/utils/module_icons.dart';
import 'package:brew_path/core/widgets/icon_badge.dart';
import 'package:brew_path/shared/models/module_model.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

String _lessonCount(int lessons) =>
    lessons == 1 ? '1 lesson' : '$lessons lessons';

/// Tinted hero at the top of the module screen: category icon + title + what
/// the module holds.
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
        IconBadge.roundedMark(
          mark: moduleMark(module.iconName),
          size: _badgeSize,
          iconSize: _iconSize,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                module.title,
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                // The course authors no blurb for a module, so the hero says
                // what it actually contains rather than inventing prose.
                _lessonCount(module.lessons.length),
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
