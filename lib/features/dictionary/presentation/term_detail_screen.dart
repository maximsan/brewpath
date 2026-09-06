import 'package:brew_path/core/widgets/error_view.dart';
import 'package:brew_path/core/widgets/loading_indicator.dart';
import 'package:brew_path/core/widgets/page_large_title.dart';
import 'package:brew_path/core/widgets/sub_screen_scaffold.dart';
import 'package:brew_path/features/dictionary/domain/dictionary_derivations.dart';
import 'package:brew_path/features/dictionary/domain/dictionary_providers.dart';
import 'package:brew_path/features/dictionary/presentation/status_chip.dart';
import 'package:brew_path/features/dictionary/presentation/term_entry_body.dart';
import 'package:brew_path/features/dictionary/presentation/term_peek_sheet.dart';
import 'package:brew_path/features/saved/domain/saved_key.dart';
import 'package:brew_path/features/saved/presentation/saved_bookmark_button.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// What the page is called when the id names no term the learner may see.
///
/// A saved link to a reference term lands here for a free learner, so it is a
/// real page rather than an error box: it is titled, and it can be left.
const String _notFoundTitle = 'Not in the dictionary';

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
          return SubScreenScaffold(
            title: _notFoundTitle,
            body: (context, scrollPadding) => ListView(
              padding: const EdgeInsets.all(AppSpacing.gutter) + scrollPadding,
              children: const [
                PageLargeTitle(_notFoundTitle),
                SizedBox(height: AppSpacing.lg),
                ErrorView(message: 'That term is not in the dictionary.'),
              ],
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
    // The bar carries the way back, the term's category as an eyebrow and the
    // bookmark. Its back control is ringed, which the design does on exactly
    // this page: it is the one bar with a control at both ends, and the ring
    // is what makes the two read at one weight.
    return SubScreenScaffold(
      title: term.term,
      eyebrow: view.categoryById(term.categoryId)?.label,
      isRinged: true,
      trailing: SavedBookmarkButton(
        savedKey: formatSavedKey(SavedKind.term, term.id),
        label: term.term,
      ),
      body: (context, scrollPadding) => SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.gutter) + scrollPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // The page heading lives here rather than inside the entry: the
            // screen owns the page's chrome, and the peek sheet reuses the
            // same entry without wanting a second title above its own.
            PageLargeTitle(term.term),
            const SizedBox(height: AppSpacing.xs),
            StatusChip(
              status: dictionaryStatusOf(term, view.completedLessonIds),
            ),
            const SizedBox(height: AppSpacing.sm),
            TermEntryBody(
              view: view,
              term: term,
              // A related term opens as a peek, not a push: following a
              // thread through the vocabulary should not bury the entry you
              // started on.
              onRelatedTap: (id) => showTermPeekSheet(context, id),
            ),
          ],
        ),
      ),
    );
  }
}
