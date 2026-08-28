import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/widgets/error_view.dart';
import 'package:brew_path/core/widgets/loading_indicator.dart';
import 'package:brew_path/features/mini_games/domain/mini_game_providers.dart';
import 'package:brew_path/features/mini_games/domain/mini_game_run.dart';
import 'package:brew_path/shared/models/content/mini_game_format.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// What the game is and how it is played, before any round runs.
///
/// Backing out here costs nothing: no run has begun, so there is nothing to
/// abandon and nothing to write.
class MiniGameIntroScreen extends ConsumerWidget {
  /// Creates a [MiniGameIntroScreen].
  const MiniGameIntroScreen({required this.formatId, super.key});

  /// Catalog id of the format being introduced.
  final String formatId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final format = ref.watch(miniGameFormatProvider(formatId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mini-game'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Close',
          onPressed: () => context.canPop()
              ? context.pop()
              : context.goNamed(AppRoutes.learn.name),
        ),
      ),
      body: format.when(
        loading: () => Semantics(
          label: 'Loading the mini-game',
          child: const LoadingIndicator(),
        ),
        error: (error, _) => Semantics(
          label: 'That mini-game could not be loaded.',
          excludeSemantics: true,
          child: ErrorView(message: '$error'),
        ),
        data: (data) => data == null
            ? Semantics(
                label: 'That mini-game is not in the catalog.',
                excludeSemantics: true,
                child: const ErrorView(
                  message: 'That mini-game is not in the catalog.',
                ),
              )
            : _Intro(format: data),
      ),
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro({required this.format});

  final MiniGameFormat format;

  static const double _stepNumberWidth = 24;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    format.topic,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: mood.inkMute,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Semantics(
                    header: true,
                    child: Text(
                      format.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: mood.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    format.blurb,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: mood.inkMute,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'HOW TO PLAY',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: mood.inkMute,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ..._steps(theme, mood),
                ],
              ),
            ),
          ),
          _playButton(context),
        ],
      ),
    );
  }

  /// The numbered how-to-play steps the format authors.
  List<Widget> _steps(ThemeData theme, MoodColors mood) => [
    for (var index = 0; index < format.steps.length; index++)
      Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: _stepNumberWidth,
              child: Text(
                '${index + 1}',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: mood.accentText,
                ),
              ),
            ),
            Expanded(
              child: Text(
                format.steps[index],
                style: theme.textTheme.bodyMedium?.copyWith(color: mood.ink),
              ),
            ),
          ],
        ),
      ),
  ];

  /// Whether this build carries a renderer for this game's kind.
  ///
  /// The catalog row no longer answers this — its tap is about tier — so the
  /// intro is where a learner finds out, on the action they came to take. A
  /// disabled action naming its own state is honest; a row that greys itself
  /// is mistaken for a paywall.
  bool get _isPlayable => playableMiniGameIds.contains(format.id);

  Widget _playButton(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.lg,
      0,
      AppSpacing.lg,
      AppSpacing.lg,
    ),
    child: SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: _isPlayable
            ? () => context.goNamed(
                AppRoutes.miniGamePlay.name,
                pathParameters: {'gameId': format.id},
              )
            : null,
        child: Text(_isPlayable ? 'Play' : 'Not playable yet'),
      ),
    ),
  );
}
