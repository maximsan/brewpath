import 'dart:async';
import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/widgets/error_view.dart';
import 'package:brew_path/core/widgets/loading_indicator.dart';
import 'package:brew_path/features/dictionary/domain/dictionary_derivations.dart';
import 'package:brew_path/features/dictionary/domain/dictionary_providers.dart';
import 'package:brew_path/features/dictionary/presentation/category_index.dart';
import 'package:brew_path/features/dictionary/presentation/dictionary_filter_control.dart';
import 'package:brew_path/features/dictionary/presentation/dictionary_masthead.dart';
import 'package:brew_path/features/dictionary/presentation/dictionary_quick_chips.dart';
import 'package:brew_path/features/dictionary/presentation/dictionary_term_list.dart';
import 'package:brew_path/features/dictionary/presentation/search_mark.dart';
import 'package:brew_path/shared/models/content/dictionary_category.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The design's search mark, at its drawn size (`dictionary.jsx:179`).
const double _searchMarkSize = 17;

/// Dictionary home: search, filter, and every term under its category.
class DictionaryHomeScreen extends ConsumerWidget {
  /// Creates a [DictionaryHomeScreen].
  const DictionaryHomeScreen({super.key});

  /// The screen's name, and the header action that reaches it.
  ///
  /// `Coffee Dictionary` (`dictionary.jsx:297`), not `Dictionary`: the course
  /// is about one subject and the shelf says so.
  static const title = 'Coffee Dictionary';

  /// The kicker over it, which carries how many terms the shelf holds
  /// (`dictionary.jsx:451`) — the count is the part that makes it inform
  /// rather than decorate.
  static String kickerFor(int terms) => 'Reference · $terms terms';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(dictionaryViewProvider);

    return Scaffold(
      // No bar title: the name is a page heading below, where the design puts
      // it, so it can set at display size under its kicker.
      appBar: AppBar(),
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

  /// The category being browsed, or null on the index.
  ///
  /// The design opens on the index and drills in (`dictionary.jsx:414`): a
  /// learner arrives wanting a subject, not a scroll of seventy-three terms.
  DictionaryCategory? _category;

  /// Whether the index is what to show — nothing narrowed, nothing searched.
  bool get _onIndex =>
      _category == null && _query.isEmpty && _filter == DictionaryFilter.all;

  /// The terms surviving the category, the filter and the query, in bank
  /// order.
  List<DictionaryTerm> get _visible {
    final inCategory = _category == null
        ? widget.view.terms
        : widget.view.terms
              .where((term) => term.categoryId == _category!.id)
              .toList();

    return searchDictionary(
      filterDictionary(inCategory, _filter, widget.view.completedLessonIds),
      _query,
      categories: widget.view.categories,
    );
  }

  void _openTerm(String termId) =>
      unawaited(context.pushDictionaryTerm(termId));

  @override
  Widget build(BuildContext context) {
    final visible = _visible;
    final mood = context.mood;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DictionaryMasthead(
          terms: widget.view.terms.length,
          category: _category,
          onClear: () => setState(() => _category = null),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.gutter,
            AppSpacing.sm,
            AppSpacing.gutter,
            AppSpacing.sm,
          ),
          child: TextField(
            onChanged: (value) => setState(() => _query = value),
            decoration: InputDecoration(
              hintText: 'Search terms, e.g. crema, bloom…',
              prefixIcon: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: SearchMark(size: _searchMarkSize, color: mood.inkMute),
              ),
              prefixIconConstraints: const BoxConstraints.tightFor(
                width: _searchMarkSize + AppSpacing.md,
                height: _searchMarkSize + AppSpacing.md,
              ),
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        DictionaryFilterControl(
          selected: _filter,
          counts: widget.view.counts,
          onSelected: (filter) => setState(() => _filter = filter),
        ),
        const SizedBox(height: AppSpacing.sm),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
          child: DictionaryQuickChips(),
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: _onIndex
              ? SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.gutter,
                  ),
                  child: CategoryIndex(
                    categories: widget.view.categories,
                    terms: widget.view.terms,
                    onOpen: (category) => setState(() => _category = category),
                  ),
                )
              : visible.isEmpty
              ? const DictionaryNoMatches()
              : DictionaryTermList(
                  view: widget.view,
                  visible: visible,
                  onOpen: _openTerm,
                ),
        ),
      ],
    );
  }
}
