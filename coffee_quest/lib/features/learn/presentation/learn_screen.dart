import 'package:coffee_quest/core/constants/app_strings.dart';
import 'package:coffee_quest/core/utils/module_icons.dart';
import 'package:coffee_quest/core/widgets/error_view.dart';
import 'package:coffee_quest/core/widgets/loading_indicator.dart';
import 'package:coffee_quest/core/widgets/section_header.dart';
import 'package:coffee_quest/features/learn/domain/learn_providers.dart';
import 'package:coffee_quest/features/learn/presentation/module_card_widget.dart';
import 'package:coffee_quest/features/progress/domain/progress_providers.dart';
import 'package:coffee_quest/shared/models/lesson_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LearnScreen extends ConsumerWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todayLessonProvider);
    final modules = ref.watch(modulesWithProgressProvider);
    final allLessons = ref.watch(allLessonsWithModuleProvider);
    final gameTypeCounts = ref.watch(gameTypePracticeCountsProvider);
    final completedLessons = ref.watch(completedLessonsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.tabLearn)),
      body: modules.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorView(message: '$e'),
        data: (list) => ListView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            _TodayCard(today: today.asData?.value),
            const SizedBox(height: 24),
            const SectionHeader('Practice any lesson'),
            const SizedBox(height: 12),
            _PracticeAnyLessonSection(
              lessons: allLessons.asData?.value ?? const [],
              completedIds:
                  completedLessons.asData?.value
                      .map((r) => r.lessonId)
                      .toSet() ??
                  const {},
            ),
            const SizedBox(height: 24),
            const SectionHeader('Practice by game type'),
            const SizedBox(height: 12),
            _PracticeByGameTypeSection(
              counts: gameTypeCounts.asData?.value ?? const {},
            ),
            const SizedBox(height: 24),
            const SectionHeader('Modules'),
            const SizedBox(height: 12),
            for (var i = 0; i < list.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              ModuleCardWidget(item: list[i]),
            ],
          ],
        ),
      ),
    );
  }
}

/// Hero card for the day's primary action. Renders the next lesson with a
/// prominent `Start` CTA, or a friendly caught-up state when nothing is due.
class _TodayCard extends StatelessWidget {
  const _TodayCard({required this.today});

  final LessonModel? today;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final lesson = today;

    return Card(
      margin: EdgeInsets.zero,
      color: colors.primaryContainer,
      child: lesson == null
          ? _buildCaughtUp(theme, colors)
          : _buildLesson(context, theme, colors, lesson),
    );
  }

  Widget _buildLesson(
    BuildContext context,
    ThemeData theme,
    ColorScheme colors,
    LessonModel lesson,
  ) {
    return InkWell(
      onTap: () => context.go('/learn/lesson/${lesson.id}'),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_cafe,
                  size: 18,
                  color: colors.onPrimaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  "Today's lesson",
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colors.onPrimaryContainer,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              lesson.title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: colors.onPrimaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              lesson.summary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onPrimaryContainer.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _XpPill(xp: lesson.xpReward),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () => context.go('/learn/lesson/${lesson.id}'),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaughtUp(ThemeData theme, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 40, color: colors.onPrimaryContainer),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "You're all caught up!",
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colors.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'No lessons left to study.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onPrimaryContainer.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact `+XP` reward chip shown on the hero card.
class _XpPill extends StatelessWidget {
  const _XpPill({required this.xp});

  final int xp;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.onPrimaryContainer.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bolt, size: 16, color: colors.onPrimaryContainer),
          const SizedBox(width: 4),
          Text(
            '+$xp XP',
            style: theme.textTheme.labelMedium?.copyWith(
              color: colors.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Browse-all section that lists every lesson grouped by its module, so the
/// user can pick any lesson to practice without first opening a module.
class _PracticeAnyLessonSection extends StatefulWidget {
  const _PracticeAnyLessonSection({
    required this.lessons,
    required this.completedIds,
  });

  final List<LessonWithModule> lessons;
  final Set<String> completedIds;

  @override
  State<_PracticeAnyLessonSection> createState() =>
      _PracticeAnyLessonSectionState();
}

class _PracticeAnyLessonSectionState extends State<_PracticeAnyLessonSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.lessons.isEmpty) {
      return const _SectionPlaceholder(text: 'No lessons available yet.');
    }
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    // Collapsed view shows the first few; expanding reveals the rest. Stops
    // this section from dominating the screen on first paint while still
    // letting the user reach every lesson.
    const previewCount = 4;
    final list = _expanded
        ? widget.lessons
        : widget.lessons.take(previewCount).toList();

    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < list.length; i++) ...[
            if (i > 0) Divider(height: 1, color: colors.outlineVariant),
            _LessonRow(
              entry: list[i],
              completed: widget.completedIds.contains(list[i].lesson.id),
            ),
          ],
          if (widget.lessons.length > previewCount)
            InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      size: 18,
                      color: colors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _expanded
                          ? 'Show fewer'
                          : 'Show all ${widget.lessons.length} lessons',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LessonRow extends StatelessWidget {
  const _LessonRow({required this.entry, required this.completed});

  final LessonWithModule entry;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.primaryContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          moduleIcon(entry.module.iconName),
          size: 18,
          color: colors.onPrimaryContainer,
        ),
      ),
      title: Text(entry.lesson.title),
      subtitle: Text(
        entry.module.title,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colors.onSurfaceVariant,
        ),
      ),
      trailing: Icon(
        completed ? Icons.check_circle : Icons.fitness_center,
        color: completed ? colors.primary : colors.onSurfaceVariant,
      ),
      onTap: () => context.go('/learn/practice/lesson/${entry.lesson.id}'),
    );
  }
}

/// Row of chips, one per supported game type. Each chip is enabled only when
/// at least one step of that type lives in a completed lesson.
class _PracticeByGameTypeSection extends StatelessWidget {
  const _PracticeByGameTypeSection({required this.counts});

  /// `gameType` discriminator → number of practiceable steps in completed
  /// lessons.
  final Map<String, int> counts;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final entry in gameTypeLabels)
          () {
            final key = entry.$1;
            final label = entry.$2;
            final count = counts[key] ?? 0;
            final enabled = count > 0;
            return ActionChip(
              avatar: Icon(
                _iconFor(key),
                size: 18,
                color: enabled ? colors.primary : colors.onSurfaceVariant,
              ),
              label: Text(
                enabled ? '$label ($count)' : label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: enabled ? colors.onSurface : colors.onSurfaceVariant,
                ),
              ),
              onPressed: enabled
                  ? () => context.go('/learn/practice/game-type/$key')
                  : null,
            );
          }(),
      ],
    );
  }

  IconData _iconFor(String gameType) => switch (gameType) {
    'multiple_choice' => Icons.check_box_outlined,
    'drag_drop' => Icons.compare_arrows,
    'tap_order' => Icons.format_list_numbered,
    'slider' => Icons.tune,
    _ => Icons.extension_outlined,
  };
}

class _SectionPlaceholder extends StatelessWidget {
  const _SectionPlaceholder({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          text,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
