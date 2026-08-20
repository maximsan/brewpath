import 'package:brew_path/core/widgets/section_header.dart';
import 'package:brew_path/features/challenges/domain/challenge_bank.dart';
import 'package:brew_path/features/challenges/domain/challenge_providers.dart';
import 'package:brew_path/shared/models/content/brew_challenge.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const double _iconSm = 18;

/// The brews parked for later.
///
/// Renders nothing at all when the queue is empty — a header over an empty
/// list tells the learner they are missing something rather than that there is
/// nothing to miss.
class SavedChallengesList extends ConsumerWidget {
  /// Creates a [SavedChallengesList].
  const SavedChallengesList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(savedChallengesProvider).asData?.value;
    if (saved == null || saved.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.lg),
        const SectionHeader('Saved challenges'),
        const SizedBox(height: AppSpacing.sm),
        for (final challenge in saved) ...[
          _SavedRow(challenge: challenge),
          if (challenge != saved.last) const SizedBox(height: AppSpacing.xs),
        ],
      ],
    );
  }
}

class _SavedRow extends ConsumerWidget {
  const _SavedRow({required this.challenge});

  final BrewChallenge challenge;

  Future<void> _start(WidgetRef ref) async {
    await startChallenge(
      ref.read(snapshotRepositoryProvider),
      id: challenge.id,
      now: DateTime.now(),
    );
    ref
      ..invalidate(activeChallengeProvider)
      ..invalidate(savedChallengesProvider);
  }

  Future<void> _remove(WidgetRef ref) async {
    await unsaveChallenge(
      ref.read(snapshotRepositoryProvider),
      id: challenge.id,
      now: DateTime.now(),
    );
    ref.invalidate(savedChallengesProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final mood = context.mood;
    final effort = effortParts(challenge.effort);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: mood.surface,
        borderRadius: BorderRadius.circular(AppRadii.editorial),
        border: Border.all(color: mood.rule),
      ),
      child: Row(
        children: [
          Icon(Icons.local_cafe_outlined, size: _iconSm, color: mood.inkMute),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(challenge.title, style: theme.textTheme.titleSmall),
                Text(
                  [?effort.trigger, ?effort.duration].join(' · '),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: mood.inkMute,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _start(ref),
            child: const Text('Start'),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            iconSize: _iconSm,
            tooltip: 'Remove ${challenge.title} from saved',
            onPressed: () => _remove(ref),
          ),
        ],
      ),
    );
  }
}
