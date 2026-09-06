import 'dart:async';

import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/widgets/loading_indicator.dart';
import 'package:brew_path/core/widgets/sticky_action_bar.dart';
import 'package:brew_path/features/companion/domain/companion_reaction.dart';
import 'package:brew_path/features/companion/presentation/companion_celebration.dart';
import 'package:brew_path/features/learn/domain/course_completion_providers.dart';
import 'package:brew_path/features/progress/domain/progress_providers.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The Foundations ending — the one-off, full-screen completion moment.
///
/// The router presents it when the completion is due; presenting it writes
/// the acknowledgement immediately, so the moment cannot replay — a
/// force-quit mid-celebration still counts as seen. The hand-off lands on
/// Today, which by now shows Keep Sharp.
class CourseCompletionScreen extends ConsumerStatefulWidget {
  /// Creates a [CourseCompletionScreen].
  const CourseCompletionScreen({super.key});

  @override
  ConsumerState<CourseCompletionScreen> createState() =>
      _CourseCompletionScreenState();
}

class _CourseCompletionScreenState
    extends ConsumerState<CourseCompletionScreen> {
  @override
  void initState() {
    super.initState();
    unawaited(
      ackCourseCompletion(
        ref.read(snapshotRepositoryProvider),
        DateTime.now(),
      ).then((_) {
        if (mounted) ref.invalidate(courseCompletionAckedProvider);
      }),
    );
  }

  /// The redirect reads the gate's last *resolved* value, so navigating
  /// before the recomputation lands would bounce straight back here. Awaiting
  /// the (idempotent) ack and the gate closes that window; the navigation
  /// happens regardless, because a failed write means the moment is still
  /// due and the redirect returning the user here is the designed outcome.
  Future<void> _handOffToKeepSharp() async {
    try {
      await ackCourseCompletion(
        ref.read(snapshotRepositoryProvider),
        DateTime.now(),
      );
      ref.invalidate(courseCompletionAckedProvider);
      await ref.read(courseCompletionDueProvider.future);
    } finally {
      if (mounted && context.mounted) {
        context.goNamed(AppRoutes.learn.name);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;

    final lessons = ref.watch(completedLessonsProvider);
    final cards = ref.watch(collectedCardsProvider);
    final streak = ref.watch(streakProvider);
    // The ending must never paint "0 lessons" for a loading frame; the
    // moment waits for its own numbers.
    if (!lessons.hasValue || !cards.hasValue || !streak.hasValue) {
      return const Scaffold(body: LoadingIndicator());
    }
    final stats = (
      lessons: lessons.value?.count ?? 0,
      cards: cards.value?.length ?? 0,
      streak: streak.value ?? 0,
    );
    return Scaffold(
      // The bar takes the bottom inset itself, so this must not consume it
      // first — doing both pads the safe area twice.
      body: SafeArea(
        bottom: false,
        child: StickyActionBar(
          label: 'Start Keep Sharp',
          onPressed: _handOffToKeepSharp,
          // Centres when the moment fits and scrolls when it does not, which
          // the bar owns — the design's `margin: auto 0` on this screen.
          content: Padding(
            // Vertical as well as horizontal: the bar reserves room under the
            // content but nothing above it, and the celebration sat flush
            // against the safe-area edge on a tall run without this.
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.gutter,
              vertical: AppSpacing.lg,
            ),
            child: _celebration(theme, mood, stats),
          ),
        ),
      ),
    );
  }

  Widget _celebration(ThemeData theme, MoodColors mood, _Stats stats) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Center(
          child: CompanionCelebration(
            reaction: CompanionReaction.courseComplete,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Course complete',
          textAlign: TextAlign.center,
          style: theme.textTheme.labelLarge?.copyWith(color: mood.inkMute),
        ),
        const SizedBox(height: AppSpacing.xs),
        Semantics(
          header: true,
          child: Text(
            'You finished Beginner Foundations',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: mood.ink,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _statsSummary(stats),
      ],
    );
  }

  Widget _statsSummary(_Stats stats) {
    return Semantics(
      label:
          'What you did: ${stats.lessons} lessons completed, '
          '${stats.cards} cards collected, '
          'a ${stats.streak} day streak.',
      child: Column(
        children: [
          _StatRow(label: 'Lessons completed', value: '${stats.lessons}'),
          _StatRow(label: 'Cards collected', value: '${stats.cards}'),
          _StatRow(label: 'Day streak', value: '${stats.streak}'),
        ],
      ),
    );
  }
}

/// The three derived completion stats, travelling together.
typedef _Stats = ({int lessons, int cards, int streak});

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(color: mood.inkMute),
          ),
          Text(
            value,
            // `titleMedium` is `bodyLarge`'s rung in the control face — the
            // same size, emphasised the one way the bundle can.
            style: theme.textTheme.titleMedium?.copyWith(color: mood.ink),
          ),
        ],
      ),
    );
  }
}
