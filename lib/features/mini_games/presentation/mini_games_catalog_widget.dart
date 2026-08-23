import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/features/mini_games/domain/mini_game_kinds.dart';
import 'package:brew_path/shared/models/content/mini_game_format.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The Mini-games group under Learn → Practice again.
///
/// Games are grouped by **kind**, in the fixed order [miniGameKinds] declares,
/// each group keeping catalog order internally. A learner arrives wanting a
/// mechanic rather than a topic, and a flat list of thirteen made them read all
/// thirteen to find the two that match. The order does not derive from the
/// catalog, so adding a game never reshuffles the shelf.
///
/// The row leads with the game's own name and carries the topic it drills as
/// the eyebrow — the design reference had these inverted, corrected alongside
/// this build.
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

  static const SizedBox _headingGap = SizedBox(height: AppSpacing.xs);
  static const SizedBox _groupGap = SizedBox(height: AppSpacing.md);

  @override
  Widget build(BuildContext context) {
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

    final groups = groupCatalogByKind(formats);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < groups.length; index++) ...[
          if (index > 0) _groupGap,
          _GroupHeading(label: groups[index].label),
          _headingGap,
          _GroupCard(games: groups[index].games),
        ],
      ],
    );
  }
}

class _GroupHeading extends StatelessWidget {
  const _GroupHeading({required this.label});

  final String label;

  static const double _letterSpacing = 0.8;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: context.mood.inkMute,
          letterSpacing: _letterSpacing,
        ),
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.games});

  final List<MiniGameFormat> games;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          for (var index = 0; index < games.length; index++) ...[
            if (index > 0) Divider(height: 1, color: mood.rule),
            _FormatRow(format: games[index]),
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
