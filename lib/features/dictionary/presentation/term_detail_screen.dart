import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/widgets/error_view.dart';
import 'package:brew_path/core/widgets/loading_indicator.dart';
import 'package:brew_path/features/dictionary/domain/dictionary_derivations.dart';
import 'package:brew_path/features/dictionary/domain/dictionary_providers.dart';
import 'package:brew_path/features/dictionary/presentation/dictionary_status_style.dart';
import 'package:brew_path/features/dictionary/presentation/term_entry_body.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The full entry for one dictionary term.
class TermDetailScreen extends ConsumerWidget {
  /// Creates a [TermDetailScreen].
  const TermDetailScreen({required this.termId, super.key});

  /// The term to show.
  final String termId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(dictionaryViewProvider);

    return view.when(
      loading: () => const Scaffold(body: LoadingIndicator()),
      error: (error, _) => Scaffold(body: ErrorView(message: '$error')),
      data: (data) {
        final term = data.termById(termId);
        if (term == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const ErrorView(
              message: 'That term is not in the dictionary.',
            ),
          );
        }
        return _TermDetail(term: term, view: data);
      },
    );
  }
}

class _TermDetail extends ConsumerWidget {
  const _TermDetail({required this.term, required this.view});

  final DictionaryTerm term;
  final DictionaryView view;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = dictionaryStatusOf(term, view.completedLessonIds);
    final lessonId = term.lessonId;

    return Scaffold(
      appBar: AppBar(
        title: Text(term.term),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: Center(
              child: Text(
                status.label,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.gutter),
        child: FutureBuilder<String?>(
          future: _lessonTitle(ref, lessonId),
          builder: (context, snapshot) => TermEntryBody(
            term: term,
            status: status,
            lessonTitle: snapshot.data,
            onRelatedTap: (id) => context.pushNamed(
              AppRoutes.dictionaryTerm.name,
              pathParameters: {'termId': id},
            ),
          ),
        ),
      ),
    );
  }

  /// The title of the lesson that teaches this term, when one does.
  Future<String?> _lessonTitle(WidgetRef ref, String? lessonId) async {
    if (lessonId == null) return null;
    final lesson = await ref
        .read(contentRepositoryProvider)
        .getLessonById(lessonId);
    return lesson?.title;
  }
}
