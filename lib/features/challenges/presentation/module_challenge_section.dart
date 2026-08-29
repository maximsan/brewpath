import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/features/challenges/domain/challenge_bank.dart';
import 'package:brew_path/features/challenges/domain/challenge_providers.dart';
import 'package:brew_path/shared/models/content/brew_challenge.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const double _cardRadius = 12;
const double _eyebrowLetterSpacing = 0.6;

/// The capstone a finished module offers, or nothing at all.
///
/// Renders **nothing** — no header, no gap, no placeholder — while the module
/// is unfinished or has no capstone. A section that announces itself and then
/// says it has nothing to give is worse than one that is not there.
class ModuleChallengeSection extends ConsumerWidget {
  /// Creates a [ModuleChallengeSection].
  const ModuleChallengeSection({required this.moduleId, super.key});

  /// The module whose capstone this offers.
  final String moduleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offer = ref.watch(moduleChallengeOfferProvider(moduleId));
    final challenge = offer.asData?.value;
    if (challenge == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg),
      child: _Offer(challenge: challenge),
    );
  }
}

class _Offer extends ConsumerWidget {
  const _Offer({required this.challenge});

  final BrewChallenge challenge;

  Future<void> _start(BuildContext context, WidgetRef ref) async {
    await startChallenge(
      ref.read(snapshotRepositoryProvider),
      id: challenge.id,
      now: DateTime.now(),
    );
    if (!context.mounted) return;
    ref.invalidate(activeChallengeProvider);
    context.goNamed(AppRoutes.learn.name);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final mood = context.mood;
    final effort = effortParts(challenge.effort);

    return Card(
      margin: EdgeInsets.zero,
      color: mood.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_cardRadius),
        side: BorderSide(color: mood.accent),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'MODULE COFFEE CHALLENGE',
              style: theme.textTheme.labelSmall?.copyWith(
                color: mood.accentText,
                letterSpacing: _eyebrowLetterSpacing,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              challenge.title,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              challenge.instruction,
              style: theme.textTheme.bodyMedium?.copyWith(color: mood.inkMute),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              [?effort.trigger, ?effort.duration].join(' · '),
              style: theme.textTheme.labelMedium?.copyWith(color: mood.inkMute),
            ),
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton(
                onPressed: () => _start(context, ref),
                child: const Text('Start Challenge'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
