import 'package:brew_path/core/widgets/error_view.dart';
import 'package:brew_path/core/widgets/loading_indicator.dart';
import 'package:brew_path/features/dictionary/domain/dictionary_providers.dart';
import 'package:brew_path/features/dictionary/presentation/term_entry_body.dart';
import 'package:brew_path/features/dictionary/presentation/term_peek_sheet.dart';
import 'package:brew_path/features/saved/domain/saved_key.dart';
import 'package:brew_path/features/saved/presentation/saved_bookmark_button.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      loading: () => Scaffold(
        body: Semantics(
          label: 'Loading the term',
          child: const LoadingIndicator(),
        ),
      ),
      error: (error, _) => Scaffold(
        body: Semantics(
          label: 'The term could not be loaded',
          child: ErrorView(message: '$error'),
        ),
      ),
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

class _TermDetail extends StatelessWidget {
  const _TermDetail({required this.term, required this.view});

  final DictionaryTerm term;
  final DictionaryView view;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The bar carries the way back and the bookmark, and nothing else: the
      // term is a page heading below, where the design puts it, so it can set
      // at display size and take a status chip beside it.
      appBar: AppBar(
        actions: [
          SavedBookmarkButton(
            savedKey: formatSavedKey(SavedKind.term, term.id),
            label: term.term,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.gutter),
        child: TermEntryBody(
          view: view,
          term: term,
          heading: true,
          // A related term opens as a peek, not a push: following a thread
          // through the vocabulary should not bury the entry you started on.
          onRelatedTap: (id) => showTermPeekSheet(context, id),
        ),
      ),
    );
  }
}
