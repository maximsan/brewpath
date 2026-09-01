import 'package:brew_path/features/challenges/domain/challenge_bank.dart';
import 'package:brew_path/features/challenges/domain/challenge_providers.dart';
import 'package:brew_path/shared/models/content/brew_challenge.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Offers the Coffee Challenge a just-finished lesson carries — if it has one.
///
/// **Twenty of the thirty-two lessons carry none**, so rendering nothing is
/// the common case rather than the exception, and it renders *nothing at all*:
/// no gap, no divider, no placeholder. The completion screen without a
/// challenge must be indistinguishable from a completion screen that never had
/// the possibility of one. It sits in the completion screen's sticky footer,
/// above the action, and carries the gap between the two itself — the bar
/// contributes none, so an absent offer leaves no band where it would have
/// been.
class ChallengeSuggestion extends ConsumerWidget {
  /// Creates a [ChallengeSuggestion].
  const ChallengeSuggestion({required this.lessonId, super.key});

  /// The lesson that was just finished.
  final String lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bank = ref.watch(challengeBankProvider).asData?.value;
    if (bank == null) return const SizedBox.shrink();

    final challenge = challengeForLesson(bank, lessonId);
    if (challenge == null) return const SizedBox.shrink();

    // The gap belongs to the offer rather than to its host: the sticky bar
    // adds no spacer of its own, so a lesson with no challenge leaves no trace
    // in the footer at all.
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.base),
      child: _Suggestion(challenge: challenge),
    );
  }
}

class _Suggestion extends ConsumerStatefulWidget {
  const _Suggestion({required this.challenge});

  final BrewChallenge challenge;

  @override
  ConsumerState<_Suggestion> createState() => _SuggestionState();
}

class _SuggestionState extends ConsumerState<_Suggestion> {
  /// What the learner did with the offer, so the strip can confirm it without
  /// the screen navigating away from the completion it is celebrating.
  String? _confirmation;

  Future<void> _start() async {
    await startChallenge(
      ref.read(snapshotRepositoryProvider),
      id: widget.challenge.id,
      now: DateTime.now(),
    );
    ref
      ..invalidate(activeChallengeProvider)
      ..invalidate(savedChallengesProvider);
    if (mounted) {
      setState(() => _confirmation = 'Added to Today. Log it when you brew.');
    }
  }

  Future<void> _saveForLater() async {
    await saveChallengeForLater(
      ref.read(snapshotRepositoryProvider),
      id: widget.challenge.id,
      now: DateTime.now(),
    );
    ref.invalidate(savedChallengesProvider);
    if (mounted) {
      setState(() => _confirmation = 'Saved. Find it under Saved challenges.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;
    final confirmation = _confirmation;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: mood.surface,
        borderRadius: BorderRadius.circular(AppRadii.editorial),
        border: Border.all(color: mood.accent),
      ),
      child: confirmation != null
          ? Text(
              confirmation,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: mood.inkMute),
            )
          : _offer(theme, mood),
    );
  }

  Widget _offer(ThemeData theme, MoodColors mood) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        'COFFEE CHALLENGE UNLOCKED',
        textAlign: TextAlign.center,
        style: theme.textTheme.labelSmall?.copyWith(
          color: mood.accentText,
        ),
      ),
      const SizedBox(height: AppSpacing.xs),
      Text(
        widget.challenge.title,
        textAlign: TextAlign.center,
        style: theme.textTheme.titleMedium,
      ),
      const SizedBox(height: AppSpacing.xxs),
      Text(
        widget.challenge.instruction,
        textAlign: TextAlign.center,
        style: theme.textTheme.bodyMedium?.copyWith(color: mood.inkMute),
      ),
      const SizedBox(height: AppSpacing.sm),
      // An action inside a suggestion block, not the screen's CTA — the
      // lesson's own Continue is below it and owns that role.
      FilledButton(
        onPressed: _start,
        child: const Text('Start Challenge'),
      ),
      TextButton(
        onPressed: _saveForLater,
        child: const Text('Save for later'),
      ),
    ],
  );
}
