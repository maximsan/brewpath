import 'dart:async';
import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/widgets/error_view.dart';
import 'package:brew_path/core/widgets/loading_indicator.dart';
import 'package:brew_path/core/widgets/section_header.dart';
import 'package:brew_path/features/dictionary/domain/dictionary_derivations.dart';
import 'package:brew_path/features/dictionary/domain/dictionary_providers.dart';
import 'package:brew_path/features/dictionary/presentation/dictionary_filter_chips.dart';
import 'package:brew_path/features/dictionary/presentation/term_row.dart';
import 'package:brew_path/shared/models/content/dictionary_category.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Dictionary home: search, filter, and every term under its category.
class DictionaryHomeScreen extends ConsumerWidget {
  /// Creates a [DictionaryHomeScreen].
  const DictionaryHomeScreen({super.key});

  /// The screen's title, and the header action that reaches it.
  static const title = 'Dictionary';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(dictionaryViewProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(title)),
      body: view.when(
        loading: () => Semantics(
          label: 'Loading the dictionary',
          child: const LoadingIndicator(),
        ),
        error: (error, _) => Semantics(
          label: 'The dictionary could not be loaded',
          child: ErrorView(message: '$error'),
        ),
        data: (data) => _DictionaryBody(view: data),
      ),
    );
  }
}

class _DictionaryBody extends StatefulWidget {
  const _DictionaryBody({required this.view});

  final DictionaryView view;

  @override
  State<_DictionaryBody> createState() => _DictionaryBodyState();
}

class _DictionaryBodyState extends State<_DictionaryBody> {
  String _query = '';
  DictionaryFilter _filter = DictionaryFilter.all;

  /// The terms surviving both the filter and the query, in bank order.
  List<DictionaryTerm> get _visible => searchDictionary(
    filterDictionary(
      widget.view.terms,
      _filter,
      widget.view.completedLessonIds,
    ),
    _query,
    categories: widget.view.categories,
  );

  void _openTerm(String termId) =>
      unawaited(context.pushDictionaryTerm(termId));

  @override
  Widget build(BuildContext context) {
    final visible = _visible;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.gutter,
            AppSpacing.sm,
            AppSpacing.gutter,
            AppSpacing.sm,
          ),
          child: TextField(
            onChanged: (value) => setState(() => _query = value),
            decoration: const InputDecoration(
              hintText: 'Search terms',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        DictionaryFilterChips(
          selected: _filter,
          counts: widget.view.counts,
          onSelected: (filter) => setState(() => _filter = filter),
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: visible.isEmpty
              ? const _NoMatches()
              : _TermList(
                  view: widget.view,
                  visible: visible,
                  onOpen: _openTerm,
                ),
        ),
      ],
    );
  }
}

/// The visible terms, grouped under their categories in bank order.
class _TermList extends StatelessWidget {
  const _TermList({
    required this.view,
    required this.visible,
    required this.onOpen,
  });

  final DictionaryView view;
  final List<DictionaryTerm> visible;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    final grouped = groupByCategory(visible, view.categories);

    return ListView(
      children: [
        for (final entry in grouped.entries) ...[
          SectionHeader(entry.key.label),
          _CategoryGlyphNote(category: entry.key),
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

/// Shown when a search matches nothing, so the learner knows the word is
/// absent rather than the app broken.
class _NoMatches extends StatelessWidget {
  const _NoMatches();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'No terms match that search',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Text(
            'No terms match that search.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: context.mood.inkMute),
          ),
        ),
      ),
    );
  }
}

/// A category's glyph and its one-line description, under the section header.
///
/// The glyph is named in the bank but no drawings exist yet, so every category
/// falls back to one generic mark rather than the app inventing eight.
class _CategoryGlyphNote extends StatelessWidget {
  const _CategoryGlyphNote({required this.category});

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
              AppIcon.cup,
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
