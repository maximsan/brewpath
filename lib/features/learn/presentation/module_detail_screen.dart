import 'package:coffee_quest/core/widgets/error_view.dart';
import 'package:coffee_quest/core/widgets/loading_indicator.dart';
import 'package:coffee_quest/core/widgets/section_header.dart';
import 'package:coffee_quest/features/learn/presentation/module_detail_hero_widget.dart';
import 'package:coffee_quest/features/learn/presentation/module_lesson_card_widget.dart';
import 'package:coffee_quest/features/progress/domain/progress_providers.dart';
import 'package:coffee_quest/shared/models/lesson_model.dart';
import 'package:coffee_quest/shared/models/module_model.dart';
import 'package:coffee_quest/shared/repositories/content_repository.dart';
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

          final completedIds =
              completed.asData?.value.map((r) => r.lessonId).toSet() ??
              const <String>{};

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
