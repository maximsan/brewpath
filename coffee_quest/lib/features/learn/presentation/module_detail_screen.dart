import 'package:coffee_quest/core/utils/module_icons.dart';
import 'package:coffee_quest/core/widgets/error_view.dart';
import 'package:coffee_quest/core/widgets/loading_indicator.dart';
import 'package:coffee_quest/core/widgets/section_header.dart';
import 'package:coffee_quest/features/progress/domain/progress_providers.dart';
import 'package:coffee_quest/shared/models/lesson_model.dart';
import 'package:coffee_quest/shared/models/module_model.dart';
import 'package:coffee_quest/shared/repositories/content_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ModuleDetailScreen extends ConsumerWidget {
  const ModuleDetailScreen({required this.moduleId, super.key});

  final String moduleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(contentRepositoryProvider);
    final completed = ref.watch(completedLessonsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Module')),
      body: FutureBuilder<(ModuleModel?, List<LessonModel>)>(
        future: _load(repo),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const LoadingIndicator();
          }
          if (snap.hasError) return ErrorView(message: '${snap.error}');
          final (module, lessons) = snap.data!;
          if (module == null) {
            return const ErrorView(message: 'Module not found');
          }
          final completedIds =
              completed.asData?.value.map((r) => r.lessonId).toSet() ??
              const <String>{};
          return ListView(
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              _ModuleHero(module: module),
              const SizedBox(height: 24),
              const SectionHeader('Lessons'),
              const SizedBox(height: 12),
              for (var i = 0; i < lessons.length; i++) ...[
                if (i > 0) const SizedBox(height: 8),
                _LessonCard(
                  lesson: lessons[i],
                  index: i + 1,
                  isCompleted: completedIds.contains(lessons[i].id),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<(ModuleModel?, List<LessonModel>)> _load(
    ContentRepository repo,
  ) async {
    final modules = await repo.getModules();
    final module = modules.where((m) => m.id == moduleId).firstOrNull;
    if (module == null) return (null, const <LessonModel>[]);
    final all = await repo.getLessons();
    final byId = {for (final l in all) l.id: l};
    final lessons = [
      for (final id in module.lessonIds)
        if (byId[id] != null) byId[id]!,
    ];
    return (module, lessons);
  }
}

/// Tinted hero at the top of the module screen: category icon + title +
/// description.
class _ModuleHero extends StatelessWidget {
  const _ModuleHero({required this.module});

  final ModuleModel module;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            moduleIcon(module.iconName),
            size: 28,
            color: colors.onPrimaryContainer,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                module.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                module.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A lesson row in the module's lesson list. Completed lessons re-open in
/// review mode and expose a `Review` action; new lessons start fresh.
class _LessonCard extends StatelessWidget {
  const _LessonCard({
    required this.lesson,
    required this.index,
    required this.isCompleted,
  });

  final LessonModel lesson;
  final int index;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final destination = isCompleted
        ? '/learn/lesson/${lesson.id}?review=true'
        : '/learn/lesson/${lesson.id}';

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => context.go(destination),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              _LessonBadge(index: index, isCompleted: isCompleted),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(lesson.title, style: theme.textTheme.titleSmall),
                    const SizedBox(height: 4),
                    Text(
                      lesson.summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _XpInline(xp: lesson.xpReward),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (isCompleted)
                TextButton(
                  onPressed: () => context.go(destination),
                  child: const Text('Review'),
                )
              else
                Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

/// Numbered/check badge on the leading edge of a lesson card.
class _LessonBadge extends StatelessWidget {
  const _LessonBadge({required this.index, required this.isCompleted});

  final int index;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final background = isCompleted ? colors.primary : colors.primaryContainer;
    final foreground = isCompleted
        ? colors.onPrimary
        : colors.onPrimaryContainer;

    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: isCompleted
          ? Icon(Icons.check, size: 20, color: foreground)
          : Text(
              '$index',
              style: theme.textTheme.titleSmall?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w700,
              ),
            ),
    );
  }
}

/// Inline `+N XP` label shown beneath each lesson row.
class _XpInline extends StatelessWidget {
  const _XpInline({required this.xp});

  final int xp;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.bolt, size: 14, color: colors.onSurfaceVariant),
        const SizedBox(width: 2),
        Text(
          '+$xp XP',
          style: theme.textTheme.labelSmall?.copyWith(
            color: colors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
