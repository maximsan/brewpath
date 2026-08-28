import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/features/challenges/domain/challenge_bank.dart';
import 'package:brew_path/features/challenges/domain/challenge_providers.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const double _iconMd = 22;
const double _eyebrowLetterSpacing = 0.6;

/// The challenge stamped onto a collectible card.
///
/// Shows nothing on a card the learner has not earned: earning the card is the
/// gate, and offering a brew from a card still to be unlocked would advertise
/// content they cannot reach.
class CardStampSection extends ConsumerWidget {
  /// Creates a [CardStampSection].
  const CardStampSection({
    required this.cardId,
    required this.isCollected,
    super.key,
  });

  /// The collectible this section sits on.
  final String cardId;

  /// Whether the learner has earned that collectible.
  final bool isCollected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isCollected) return const SizedBox.shrink();

    final bank = ref.watch(challengeBankProvider).asData?.value;
    if (bank == null) return const SizedBox.shrink();

    final challenge = challengeForCard(bank, cardId);
    if (challenge == null) return const SizedBox.shrink();

    final completed =
        ref.watch(completedChallengesProvider).asData?.value ??
        const <String>{};
    final done = completed.contains(challenge.id);

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg),
      child: _Stamp(title: challenge.title, done: done),
    );
  }
}

class _Stamp extends StatelessWidget {
  const _Stamp({required this.title, required this.done});

  final String title;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;
    final tint = done ? mood.sage : mood.inkMute;

    return Semantics(
      label: done
          ? '$title, coffee challenge, brewed'
          : '$title, coffee challenge, not brewed yet',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.chrome),
          border: Border.all(color: mood.rule),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'CHALLENGE',
              style: theme.textTheme.labelSmall?.copyWith(
                color: mood.inkMute,
                fontWeight: FontWeight.w700,
                letterSpacing: _eyebrowLetterSpacing,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                // `verified` has no counterpart in the design's family, so a
                // stamped card keeps it while an unstamped one takes the cup.
                if (done)
                  Icon(Icons.verified, size: _iconMd, color: tint)
                else
                  IconMark(AppIcon.cup, size: _iconMd, color: tint),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(title, style: theme.textTheme.titleSmall),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              done ? 'Brewed' : 'Not brewed yet',
              style: theme.textTheme.bodySmall?.copyWith(color: tint),
            ),
          ],
        ),
      ),
    );
  }
}
