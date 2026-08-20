import 'package:brew_path/core/widgets/error_view.dart';
import 'package:brew_path/core/widgets/loading_indicator.dart';
import 'package:brew_path/core/widgets/section_header.dart';
import 'package:brew_path/features/challenges/presentation/module_challenge_section.dart';
import 'package:brew_path/features/learn/presentation/module_detail_hero_widget.dart';
import 'package:brew_path/features/learn/presentation/module_lesson_card_widget.dart';
import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:brew_path/features/progress/domain/progress_providers.dart';
import 'package:brew_path/shared/models/lesson_model.dart';
import 'package:brew_path/shared/models/module_model.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Module detail: lists the module's lessons with progress and a start CTA.
class ModuleDetailScreen extends ConsumerWidget {
  /// Creates a [ModuleDetailScreen].
  const ModuleDetailScreen({required this.moduleId, super.key});

  /// Id of the module to display.
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

          if (snap.hasError) {
            return ErrorView(message: '${snap.error}');
          }

          final (module, lessons) = snap.data!;
          if (module == null) {
            return const ErrorView(message: 'Module not found');
          }

          final records = completed.asData?.value ?? const [];
          final completedIds = records.map((r) => r.lessonId).toSet();
          final masteryById = {
            for (final record in records) record.lessonId: record.mastery,
          };
          // The lesson the user is up to: the first one they have not finished.
          final currentId = lessons
              .where((l) => !completedIds.contains(l.id))
              .firstOrNull
              ?.id;

          return ListView(
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              ModuleHeroWidget(module: module),
              const SizedBox(height: 24),
              const SectionHeader('Lessons'),
              const SizedBox(height: 12),
              for (var i = 0; i < lessons.length; i++) ...[
                if (i > 0) const SizedBox(height: 8),
                ModuleLessonCardWidget(
                  lesson: lessons[i],
                  isCompleted: completedIds.contains(lessons[i].id),
                  isCurrent: lessons[i].id == currentId,
                  mastery: masteryById[lessons[i].id] ?? MasteryResult.unscored,
                ),
              ],
              ModuleChallengeSection(moduleId: moduleId),
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
    if (module == null) {
      return (null, const <LessonModel>[]);
    }

    final all = await repo.getLessons();
    final byId = {for (final l in all) l.id: l};
    final lessons = [
      for (final id in module.lessonIds)
        if (byId[id] != null) byId[id]!,
    ];

    return (module, lessons);
  }
}
