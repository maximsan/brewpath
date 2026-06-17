import 'package:coffee_quest/core/constants/app_labels.dart';
import 'package:coffee_quest/core/widgets/error_view.dart';
import 'package:coffee_quest/core/widgets/loading_indicator.dart';
import 'package:coffee_quest/core/widgets/section_header.dart';
import 'package:coffee_quest/features/learn/domain/learn_providers.dart';
import 'package:coffee_quest/features/learn/presentation/module_card_widget.dart';
import 'package:coffee_quest/features/learn/presentation/practice_any_lesson_widget.dart';
import 'package:coffee_quest/features/learn/presentation/practice_by_game_type_widget.dart';
import 'package:coffee_quest/features/learn/presentation/today_card_widget.dart';
import 'package:coffee_quest/features/progress/domain/progress_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Learn tab: today's lesson, the module list, and practice sections.
class LearnScreen extends ConsumerWidget {
  /// Creates a [LearnScreen].
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todayLessonProvider);
    final modules = ref.watch(modulesWithProgressProvider);
    final allLessons = ref.watch(allLessonsWithModuleProvider);
    final gameTypeCounts = ref.watch(gameTypePracticeCountsProvider);
    final completedLessons = ref.watch(completedLessonsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppLabels.tabLearn)),
      body: modules.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorView(message: '$e'),
        data: (list) => ListView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            TodayCardWidget(today: today.asData?.value),
            const SizedBox(height: 24),
            const SectionHeader('Practice any lesson'),
            const SizedBox(height: 12),
            PracticeAnyLessonWidget(
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
            PracticeByGameTypeWidget(
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
