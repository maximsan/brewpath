import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/swipe/swipe_geometry.dart';
import 'package:brew_path/core/swipe/swipe_hint.dart';
import 'package:brew_path/core/swipe/swipe_hint_caption.dart';
import 'package:brew_path/core/swipe/swipe_surface.dart';
import 'package:brew_path/core/utils/module_icons.dart';
import 'package:brew_path/core/widgets/section_header.dart';
import 'package:brew_path/features/dictionary/domain/dictionary_derivations.dart';
import 'package:brew_path/features/dictionary/domain/dictionary_providers.dart';
import 'package:brew_path/features/dictionary/domain/save_swipe_nudge.dart';
import 'package:brew_path/features/dictionary/presentation/term_row.dart';
import 'package:brew_path/features/saved/domain/saved_key.dart';
import 'package:brew_path/features/saved/domain/saved_providers.dart';
import 'package:brew_path/shared/models/content/dictionary_category.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The visible terms, grouped under their categories in bank order.
///
/// A sliver rather than a list of its own: the page scrolls as one now, so
/// that the shelf's title can leave the top the way the design has it — and a
/// sliver is what keeps seventy-odd rows building as they are reached rather
/// than all at once.
class DictionaryTermList extends ConsumerWidget {
  /// Creates a [DictionaryTermList].
  const DictionaryTermList({
    required this.view,
    required this.visible,
    required this.onOpen,
    this.grouped = true,
    this.isBrowsing = true,
    super.key,
  });

  /// How far the hint nudges a row, rightwards — `nudge: 40`.
  static const double _nudge = 40;

  /// The hint's words.
  static const String hintLabel = 'Swipe a term right to save it';

  /// The whole view, for each term's status.
  final DictionaryView view;

  /// The terms to draw, already filtered and searched.
  final List<DictionaryTerm> visible;

  /// Called with the id of the term the learner opened.
  final ValueChanged<String> onOpen;

  /// Whether each category heads its own run of rows. Off inside a category,
  /// where the page title already names it and a header would repeat it.
  final bool grouped;

  /// Whether this is a browse list rather than search results.
  ///
  /// Only a browse list is nudged: a result list moves under the learner as
  /// they type, and a row sliding there reads as a glitch.
  final bool isBrowsing;

  /// Whether the hint may run here at all.
  ///
  /// The nudge is picked by counting terms, which only says anything about
  /// what is on screen when nothing else takes vertical room between them —
  /// so a [grouped] run, with its headers and category notes, is left alone.
  bool get _mayNudge => isBrowsing && !grouped;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(savedKeysProvider).value ?? const <String>{};
    final nudgeId = _mayNudge
        ? firstUnsavedAboveFold(
            [for (final term in visible) term.id],
            isSaved: (id) => saved.contains(formatSavedKey(SavedKind.term, id)),
          )
        : null;

    return SwipeHint(
      surface: SwipeSurface.dictionary,
      nudge: _nudge,
      // With every reachable row already saved there is nothing to
      // demonstrate, so nothing nudges and no caption renders.
      enabled: nudgeId != null,
      builder: (context, hint) => _rows(context, hint: hint, nudgeId: nudgeId),
    );
  }

  Widget _rows(
    BuildContext context, {
    required SwipeHintState hint,
    required String? nudgeId,
  }) {
    final groups = groupByCategory(visible, view.categories);

    return SliverList.list(
      children: [
        if (nudgeId != null)
          SwipeHintCaption(
            show: hint.showing,
            aim: SwipeAim.back,
            label: hintLabel,
          ),
        for (final entry in groups.entries) ...[
          if (grouped) ...[
            // At the gutter like every line under it; the header carries no
            // inset of its own, and unpadded it sat flush to the screen edge.
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.gutter,
              ),
              child: SectionHeader(entry.key.label),
            ),
            _CategoryNote(category: entry.key),
          ],
          for (final term in entry.value)
            TermRow(
              term: term,
              status: dictionaryStatusOf(term, view.completedLessonIds),
              onTap: () => onOpen(term.id),
              nudge: term.id == nudgeId ? hint.offset : 0,
              onSaved: hint.markUsed,
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
