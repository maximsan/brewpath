import 'dart:async';
import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/widgets/error_view.dart';
import 'package:brew_path/core/widgets/loading_indicator.dart';
import 'package:brew_path/core/widgets/sub_screen_scaffold.dart';
import 'package:brew_path/features/dictionary/domain/dictionary_derivations.dart';
import 'package:brew_path/features/dictionary/domain/dictionary_providers.dart';
import 'package:brew_path/features/dictionary/presentation/category_index.dart';
import 'package:brew_path/features/dictionary/presentation/dictionary_filter_control.dart';
import 'package:brew_path/features/dictionary/presentation/dictionary_masthead.dart';
import 'package:brew_path/features/dictionary/presentation/dictionary_quick_chips.dart';
import 'package:brew_path/features/dictionary/presentation/dictionary_term_list.dart';
import 'package:brew_path/features/dictionary/presentation/search_mark.dart';
import 'package:brew_path/features/dictionary/presentation/term_of_day_banner.dart';
import 'package:brew_path/shared/models/content/dictionary_category.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The design's search mark, at its drawn size.
const double _searchMarkSize = 17;

/// The inset the practice chips take when they are fixed under the filters.
const EdgeInsets _chipPadding = EdgeInsets.fromLTRB(
  AppSpacing.gutter,
  AppSpacing.sm,
  AppSpacing.gutter,
  0,
);

/// Dictionary home: search, filter, and every term under its category.
class DictionaryHomeScreen extends ConsumerWidget {
  /// Creates a [DictionaryHomeScreen].
  const DictionaryHomeScreen({super.key});

  /// The screen's name, and the header action that reaches it.
  ///
  /// `Coffee Dictionary`, not `Dictionary`: the course is about one subject
  /// and the shelf says so.
  static const title = 'Coffee Dictionary';

  /// The kicker over it, which carries how many terms the shelf holds — the
  /// count is the part that makes it inform rather than decorate.
  static String kickerFor(int terms) => 'Reference · $terms terms';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(dictionaryViewProvider);

    return view.when(
      loading: () => Scaffold(
        body: Semantics(
          label: 'Loading the dictionary',
          child: const LoadingIndicator(),
        ),
      ),
      error: (error, _) => Scaffold(
        body: Semantics(
          label: 'The dictionary could not be loaded',
          child: ErrorView(message: '$error'),
        ),
      ),
      data: (data) => _DictionaryBody(view: data),
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
  /// The design opens on the index and drills in: a learner arrives wanting a
  /// subject, not a scroll of seventy-three terms.
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

    // The shelf's own name titles the page at the top; the bar takes it over
    // once that has scrolled away. Drilled into a category, both become the
    // category — the design retitles the page rather than stacking a
    // breadcrumb on it.
    final name = _category?.label ?? DictionaryHomeScreen.title;

    return SubScreenScaffold(
      title: name,
      // Back leaves the category first and the screen second, which is the
      // design's own rule: a drill-down is a place, so it has to be a step you
      // can take back.
      onBack: _category != null
          ? () => setState(() => _category = null)
          : () => Navigator.of(context).maybePop(),
      // The category is what identifies the content, so the bar clears with
      // it. This is the page the reset exists for: without it, drilling in
      // leaves a compact title standing over a page that has jumped back to
      // the top.
      resetKey: _category?.id,
      body: (context, scrollPadding) => SingleChildScrollView(
        // One scroll, so the shelf's title can leave the top the way every
        // other pushed page's does. It used to be fixed above a scroller,
        // which is why the bar had nothing to take over from.
        padding: scrollPadding.copyWith(bottom: AppSpacing.xl),
        child: Column(
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
                    child: SearchMark(
                      size: _searchMarkSize,
                      color: mood.inkMute,
                    ),
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
            // The practice chips: under the filters, over the list. The design
            // puts practice between *narrowing the shelf* and *reading it*,
            // because drilling is a third thing to do here rather than a way
            // of browsing.
            //
            // Here only once the learner has started narrowing. On the index
            // they sit under Term of the Day instead — which is where the
            // design has both of them.
            if (!_onIndex) ...[
              const Padding(
                padding: _chipPadding,
                child: DictionaryQuickChips(),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            if (_onIndex)
              _index()
            else if (visible.isEmpty)
              const DictionaryNoMatches()
            else
              DictionaryTermList(
                view: widget.view,
                visible: visible,
                onOpen: _openTerm,
              ),
          ],
        ),
      ),
    );
  }

  /// What the shelf opens on: today's term, the drills, then every category.
  Widget _index() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.sm),
        // Today's term leads the index, exactly as the design draws it. Only
        // here: a learner who has started searching has already said what they
        // came for, and the offer would be in the way of it.
        TermOfDayBanner(onOpen: () => unawaited(context.pushTermOfDay())),
        const SizedBox(height: AppSpacing.md),
        const DictionaryQuickChips(),
        const SizedBox(height: AppSpacing.md),
        CategoryIndex(
          categories: widget.view.categories,
          terms: widget.view.terms,
          onOpen: (category) => setState(() => _category = category),
        ),
      ],
    ),
  );
}
