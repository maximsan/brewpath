import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/utils/module_icons.dart';
import 'package:brew_path/core/widgets/section_header.dart';
import 'package:brew_path/features/dictionary/domain/dictionary_derivations.dart';
import 'package:brew_path/features/dictionary/domain/dictionary_providers.dart';
import 'package:brew_path/features/dictionary/presentation/term_row.dart';
import 'package:brew_path/shared/models/content/dictionary_category.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
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
