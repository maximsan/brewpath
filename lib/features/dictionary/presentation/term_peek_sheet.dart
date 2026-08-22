import 'dart:async';

import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/features/dictionary/domain/dictionary_derivations.dart';
import 'package:brew_path/features/dictionary/domain/dictionary_providers.dart';
import 'package:brew_path/features/dictionary/presentation/term_entry_body.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// How much of the screen the peek sheet may take.
const double _sheetMaxHeightFraction = 0.8;

/// Opens [termId] in a sheet over whatever the learner is already looking at.
///
/// Checking a word should not cost the screen you were on — so this is a sheet
/// rather than a push, and it offers a way through to the full entry.
Future<void> showTermPeekSheet(BuildContext context, String termId) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => TermPeekSheet(termId: termId),
  );
}

/// One term, compressed into a sheet.
class TermPeekSheet extends ConsumerWidget {
  /// Creates a [TermPeekSheet].
  const TermPeekSheet({required this.termId, super.key});

  /// The term to peek at.
  final String termId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(dictionaryViewProvider).asData?.value;
    final term = view?.termById(termId);
    if (view == null || term == null) return const SizedBox.shrink();

    final maxHeight =
        MediaQuery.sizeOf(context).height * _sheetMaxHeightFraction;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.gutter),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(term.term, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.xs),
            TermEntryBody(
              term: term,
              status: dictionaryStatusOf(term, view.completedLessonIds),
              lessonTitle: null,
            ),
            const SizedBox(height: AppSpacing.md),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  final router = GoRouter.of(context);
                  Navigator.of(context).pop();
                  unawaited(
                    router.pushNamed(
                      AppRoutes.dictionaryTerm.name,
                      pathParameters: {'termId': termId},
                    ),
                  );
                },
                child: const Text('Read the full entry'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
