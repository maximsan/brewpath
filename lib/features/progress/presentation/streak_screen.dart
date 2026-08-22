import 'package:brew_path/core/widgets/loading_indicator.dart';
import 'package:brew_path/features/progress/domain/freeze_status_line.dart';
import 'package:brew_path/features/progress/domain/progress_providers.dart';
import 'package:brew_path/features/progress/domain/streak_status.dart';
import 'package:brew_path/features/progress/domain/streak_week.dart';
import 'package:brew_path/features/progress/presentation/week_strip.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The streak screen — the day count at hero size, and the one-line freeze
/// status beneath it.
///
/// Everything shown is read from the derived streak state; the screen invents
/// no rules (#232). The week strip, the milestone ring and the share button
/// arrive with their own slices (#235, #236, #237).
class StreakScreen extends ConsumerWidget {
  /// Creates a [StreakScreen].
  const StreakScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(streakStatusProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your streak'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: status.when(
        loading: () => Semantics(
          label: 'Loading your streak',
          child: const LoadingIndicator(),
        ),
        error: (error, _) => Center(
          child: Semantics(
            label: 'Your streak could not be loaded',
            child: Text('$error'),
          ),
        ),
        data: (value) => _StreakBody(
          status: value,
          weekDays: ref.watch(weekStripDaysProvider).asData?.value ?? const [],
        ),
      ),
    );
  }
}

class _StreakBody extends StatelessWidget {
  const _StreakBody({required this.status, required this.weekDays});

  final StreakStatus status;
  final List<StreakDay> weekDays;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final statusLine = freezeStatusLine(status: status, today: DateTime.now());
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // One spoken phrase for the pair — the caption is part of the
            // number's meaning, not a second announcement.
            Semantics(
              label: '${status.streak} day streak',
              excludeSemantics: true,
              child: Column(
                children: [
                  Text('${status.streak}', style: AppText.hero(mood: mood)),
                  const SizedBox(height: AppSpacing.xxs),
                  Text('DAY STREAK', style: AppText.label(mood: mood)),
                ],
              ),
            ),
            if (weekDays.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              WeekStrip(days: weekDays),
            ],
            const SizedBox(height: AppSpacing.lg),
            Text(
              statusLine,
              textAlign: TextAlign.center,
              style: AppText.support(mood: mood),
            ),
          ],
        ),
      ),
    );
  }
}
