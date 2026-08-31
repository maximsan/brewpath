import 'package:brew_path/features/challenges/domain/challenge_providers.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const double _barHeight = 8;
const double _emptyBarFraction = 0.02;

/// How many Coffee Challenges the learner has brewed, out of the course's own
/// count.
///
/// A full-width row rather than a fifth square tile: the grid above is 2×2 and
/// a fifth child renders ragged, and a stat tile has nowhere to put a
/// denominator. What this reports is a fraction, so it is drawn as one.
class ChallengeStatRow extends ConsumerWidget {
  /// Creates a [ChallengeStatRow].
  const ChallengeStatRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bank = ref.watch(challengeBankProvider).asData?.value;
    final done = ref.watch(completedChallengesProvider).asData?.value;
    if (bank == null || bank.isEmpty) return const SizedBox.shrink();

    // The denominator is the bank's own length. A literal twelve here would be
    // a count restated away from the thing that decides it.
    final total = bank.length;
    final brewed = done?.where((id) => bank.any((c) => c.id == id)).length ?? 0;

    return _StatRow(brewed: brewed, total: total);
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.brewed, required this.total});

  final int brewed;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;
    // A floor, so an untouched bar still reads as a bar rather than as a rule.
    final fraction = total == 0
        ? 0.0
        : (brewed / total).clamp(_emptyBarFraction, 1.0);

    return Semantics(
      label: 'Coffee Challenges, $brewed of $total brewed',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: mood.surface,
          borderRadius: BorderRadius.circular(AppRadii.chrome),
          border: Border.all(color: mood.rule),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'COFFEE CHALLENGES',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: mood.inkMute,
                  ),
                ),
                Text(
                  '$brewed / $total',
                  style: theme.textTheme.labelLarge,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            ClipRRect(
              borderRadius: BorderRadius.circular(_barHeight),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: _barHeight,
                backgroundColor: mood.surface2,
                color: mood.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
