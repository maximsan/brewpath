import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/utils/module_icons.dart';
import 'package:brew_path/core/widgets/section_header.dart';
import 'package:brew_path/features/dictionary/domain/dictionary_derivations.dart';
import 'package:brew_path/features/dictionary/domain/dictionary_providers.dart';
import 'package:brew_path/features/dictionary/presentation/term_row.dart';
import 'package:brew_path/shared/models/content/dictionary_category.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/off_token.dart';
import 'package:flutter/material.dart';

/// The visible terms, grouped under their categories in bank order.
///
/// A sliver rather than a list of its own: the page scrolls as one now, so
/// that the shelf's title can leave the top the way the design has it — and a
/// sliver is what keeps seventy-odd rows building as they are reached rather
/// than all at once.
class DictionaryTermList extends StatelessWidget {
  /// Creates a [DictionaryTermList].
  const DictionaryTermList({
    required this.view,
    required this.visible,
    required this.onOpen,
    this.grouped = true,
    super.key,
  });

  /// The whole view, for each term's status.
  final DictionaryView view;

  /// The terms to draw, already filtered and searched.
  final List<DictionaryTerm> visible;

  /// Called with the id of the term the learner opened.
  final ValueChanged<String> onOpen;

  /// Whether each category heads its own run of rows. Off inside a category,
  /// where the page title already names it and a header would repeat it.
  final bool grouped;

  @override
  Widget build(BuildContext context) {
    final groups = groupByCategory(visible, view.categories);

    return SliverList.list(
      children: [
        for (final entry in groups.entries) ...[
          if (grouped) ...[
            SectionHeader(entry.key.label),
            _CategoryNote(category: entry.key),
          ],
          for (final term in entry.value)
            TermRow(
              term: term,
              status: dictionaryStatusOf(term, view.completedLessonIds),
              onTap: () => onOpen(term.id),
            ),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

/// How many terms a search turned up, over the results — the mono count the
/// design draws whether or not there are any.
class DictionarySearchCount extends StatelessWidget {
  /// Creates a [DictionarySearchCount].
  const DictionarySearchCount({required this.count, super.key});

  /// How many terms survived the query.
  final int count;

  /// What the count reads, singular or plural.
  static String label(int count) =>
      '$count ${count == 1 ? 'RESULT' : 'RESULTS'}';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: OffTokens.searchCountTop.value,
        bottom: AppSpacing.xxs,
        left: AppSpacing.gutter,
        right: AppSpacing.gutter,
      ),
      child: Text(
        label(count),
        style: AppText.label(
          mood: context.mood,
          face: AppFace.mono,
          tracking: AppTracking.hint,
        ),
      ),
    );
  }
}

/// Shown when a search matches nothing, so the learner knows the word is
/// absent rather than the app broken.
class DictionaryNoMatches extends StatelessWidget {
  /// Creates a [DictionaryNoMatches].
  const DictionaryNoMatches({required this.query, super.key});

  /// What was typed, quoted back so the line is about this search.
  final String query;

  /// The line, named so a test can assert it without re-spelling it.
  ///
  /// An empty [query] is the category filter having emptied the list
  /// rather than a search. The design draws no state there at all, so
  /// that case keeps the line the app already had.
  static String message(String query) => query.isEmpty
      ? 'No terms match that search.'
      : 'No terms match \u201C$query\u201D. Try a broader word \u2014 or '
            'browse by category.';

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Semantics(
      label: query.isEmpty
          ? 'No terms match that search'
          : 'No terms match that search: $query',
      child: Padding(
        padding: const EdgeInsets.only(
          top: AppSpacing.lg,
          left: AppSpacing.gutter,
          right: AppSpacing.gutter,
        ),
        child: Text(
          message(query),
          style: AppText.support(
            mood: mood,
          ).copyWith(height: OffTokens.emptyStateLeading.value),
        ),
      ),
    );
  }
}

/// A category's glyph and its one-line description, under the section header.
///
/// [moduleMark] is the mapping — the same one the Path headers use, because a
/// topic is one topic wherever it appears; a second mapping here is how the
/// two would come to disagree about what Roasting looks like.
class _CategoryNote extends StatelessWidget {
  const _CategoryNote({required this.category});

  final DictionaryCategory category;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.gutter,
        right: AppSpacing.gutter,
        bottom: AppSpacing.xs,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExcludeSemantics(
            child: IconMark(
              moduleMark(category.id),
              size: AppSpacing.md,
              color: mood.inkMute,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              category.summary,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: mood.inkMute),
            ),
          ),
        ],
      ),
    );
  }
}
