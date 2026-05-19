import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:coffee_quest/core/widgets/error_view.dart';
import 'package:coffee_quest/core/widgets/loading_indicator.dart';
import 'package:coffee_quest/features/progress/domain/progress_providers.dart';
import 'package:coffee_quest/shared/models/lesson_model.dart';
import 'package:coffee_quest/shared/models/module_model.dart';
import 'package:coffee_quest/shared/repositories/content_repository.dart';

class ModuleDetailScreen extends ConsumerWidget {
  const ModuleDetailScreen({super.key, required this.moduleId});

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
          final completedIds = completed.asData?.value
                  .map((r) => r.lessonId)
                  .toSet() ??
              const <String>{};
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                module.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(module.description),
              const Divider(height: 32),
              for (final lesson in lessons)
                ListTile(
                  leading: Icon(
                    completedIds.contains(lesson.id)
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                    color: completedIds.contains(lesson.id)
                        ? Colors.green
                        : null,
                  ),
                  title: Text(lesson.title),
                  subtitle: Text(lesson.summary),
                  onTap: () => context.go('/learn/lesson/${lesson.id}'),
                ),
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
    final module =
        modules.where((m) => m.id == moduleId).firstOrNull;
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
