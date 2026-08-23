import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/shared/models/content/mini_game_format.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The Mini-games group under Learn → Practice again.
///
/// Every game in the catalog is listed, in catalog order. The row leads with
/// the game's own name and carries the topic it drills as the eyebrow — the
/// design reference had these inverted, corrected alongside this build.
///
/// **Every row opens its intro.** Whether a game can actually be played is a
/// fact about which renderers this build carries, and it is disclosed on the
/// intro's own action rather than here — the design puts the row's tap on tier
/// alone. A row that dimmed itself for a missing renderer looked exactly like
/// a row behind a paywall, so the catalog said "unfinished" where it meant
/// "unbuilt" and would later mean "unbought".
class MiniGamesCatalogWidget extends StatelessWidget {
  /// Creates a [MiniGamesCatalogWidget].
  const MiniGamesCatalogWidget({required this.formats, super.key});

  /// The catalog, in bank order.
  final List<MiniGameFormat> formats;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    if (formats.isEmpty) {
      return Semantics(
        label: 'No mini-games available yet.',
        child: Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              'No mini-games available yet.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      );
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          for (var index = 0; index < formats.length; index++) ...[
            if (index > 0) Divider(height: 1, color: mood.rule),
            _FormatRow(format: formats[index]),
          ],
        ],
      ),
    );
  }
}

class _FormatRow extends StatelessWidget {
  const _FormatRow({required this.format});

  final MiniGameFormat format;

  static const double _eyebrowLetterSpacing = 0.8;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;

    return Semantics(
      button: true,
      label: '${format.title}. ${format.topic}. ${format.duration}.',
      child: InkWell(
        onTap: () => context.goNamed(
          AppRoutes.miniGameIntro.name,
          pathParameters: {'gameId': format.id},
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      format.topic,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: mood.inkMute,
                        letterSpacing: _eyebrowLetterSpacing,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      format.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: mood.ink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                format.duration,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: mood.inkMute,
                ),
              ),
              Icon(Icons.chevron_right, color: mood.inkMute),
            ],
          ),
        ),
      ),
    );
  }
}
