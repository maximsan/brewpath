import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/features/challenges/domain/challenge_bank.dart';
import 'package:brew_path/features/challenges/domain/challenge_providers.dart';
import 'package:brew_path/features/challenges/domain/challenge_surface_state.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const double _iconSm = 18;

/// The capstone hanging off a module on the Path.
///
/// **Module challenges only.** The Path here lists modules; the design hangs
/// lesson challenges off lesson rows that this screen does not have, and
/// flattening seven of them under a module node would invert the hierarchy.
/// They stay reachable from lesson-complete, Today, the queue and the card.
class PathChallengeNode extends ConsumerWidget {
  /// Creates a [PathChallengeNode].
  const PathChallengeNode({required this.moduleId, super.key});

  /// The module whose capstone this shows.
  final String moduleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bank = ref.watch(challengeBankProvider).asData?.value;
    final offered = ref.watch(moduleChallengeOfferProvider(moduleId));
    if (bank == null) return const SizedBox.shrink();

    final challenge = challengeForModule(bank, moduleId);
    if (challenge == null) return const SizedBox.shrink();

    final active = ref.watch(activeChallengeProvider).asData?.value;
    final completed =
        ref.watch(completedChallengesProvider).asData?.value ??
        const <String>{};
    final saved = ref.watch(savedChallengesProvider).asData?.value ?? const [];

    final state = challengeSurfaceState(
      id: challenge.id,
      activeId: active?.id,
      completed: completed,
      saved: {for (final entry in saved) entry.id},
      offerable: offered.asData?.value != null,
    );
    // A capstone the learner cannot reach yet says nothing on the Path: the
    // module node above it already carries the lock.
    if (state == ChallengeSurfaceState.locked) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: _Node(title: challenge.title, state: state),
    );
  }
}

class _Node extends StatelessWidget {
  const _Node({required this.title, required this.state});

  final String title;
  final ChallengeSurfaceState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;
    final (label, tint) = switch (state) {
      // `sage` is "learned", never an action — which is exactly what a
      // finished brew is.
      ChallengeSurfaceState.completed => ('Done', mood.sage),
      ChallengeSurfaceState.active => ('Active', mood.accent),
      ChallengeSurfaceState.saved => ('Saved', mood.inkMute),
      ChallengeSurfaceState.available => ('Challenge', mood.inkMute),
      ChallengeSurfaceState.locked => ('Challenge', mood.inkMute),
    };

    return Semantics(
      label: '$title, coffee challenge, $label',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: mood.surface,
          borderRadius: BorderRadius.circular(AppRadii.editorial),
          border: Border.all(color: mood.rule),
        ),
        child: Row(
          children: [
            IconMark(AppIcon.cup, size: _iconSm, color: tint),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(title, style: theme.textTheme.titleSmall),
            ),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: tint,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
