import 'dart:async';

import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/widgets/error_view.dart';
import 'package:brew_path/core/widgets/loading_indicator.dart';
import 'package:brew_path/core/widgets/page_large_title.dart';
import 'package:brew_path/core/widgets/sub_screen_scaffold.dart';
import 'package:brew_path/features/lessons/presentation/replay_confirm_sheet.dart';
import 'package:brew_path/features/monetization/domain/course_entitlement.dart';
import 'package:brew_path/features/path/domain/visual_guide_providers.dart';
import 'package:brew_path/features/path/presentation/visual_guide_sheet.dart';
import 'package:brew_path/features/saved/domain/saved_cap.dart';
import 'package:brew_path/features/saved/domain/saved_key.dart';
import 'package:brew_path/features/saved/domain/saved_providers.dart';
import 'package:brew_path/features/saved/domain/saved_shelf.dart';
import 'package:brew_path/features/saved/presentation/saved_empty_view.dart';
import 'package:brew_path/features/saved/presentation/saved_group_section.dart';
import 'package:brew_path/features/saved/presentation/saved_study_row.dart';
import 'package:brew_path/features/saved/presentation/saved_upgrade_row.dart';
import 'package:brew_path/l10n/app_strings.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// How far the shelf scrolls before its bar arrives.
///
/// The design gives this one screen its own threshold — 72 where every other
/// page takes the hook's default 40.
const double _shelfScrollThreshold = 72;

/// The design's `paddingBottom: 28` under the list.
const double _designBottomPad = 28;

/// The design's `paddingTop: 22` between the title block and the groups, and
/// `marginTop: 26` between one group and the next.
const double _groupsTop = 22;
const double _groupGap = 26;

/// Everything the learner has bookmarked, in three groups.
///
/// Titled *Favorites*, as the design titles it. The feature keeps its own
/// name — the bookmark says *Save*, the Profile card and the stored field say
/// *saved* — because the title names the place and the verb names the act.
class SavedScreen extends ConsumerWidget {
  /// Creates a [SavedScreen].
  const SavedScreen({super.key});

  Future<void> _open(
    BuildContext context,
    WidgetRef ref,
    SavedItem item,
  ) async {
    switch (item.kind) {
      case SavedKind.term:
        unawaited(context.pushDictionaryTerm(item.id));
      case SavedKind.lesson:
        unawaited(context.pushLessonAskingReview(item.id));
      case SavedKind.guide:
        // Awaited, not read for its current value: nothing has asked for this
        // guide before, so a synchronous read is still unresolved and the
        // first tap would silently do nothing.
        final guide = await ref.read(earnedGuideForProvider(item.id).future);
        if (guide != null && context.mounted) {
          unawaited(showVisualGuideSheet(context, guide));
        }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shelf = ref.watch(savedShelfProvider);

    return SubScreenScaffold(
      title: context.strings.savedScreenTitle,
      // The one screen the design gives its own threshold: the shelf waits
      // until 72 where every other page's bar arrives at 40.
      threshold: _shelfScrollThreshold,
      body: (context, scrollPadding) => shelf.when(
        loading: () => Semantics(
          label: context.strings.savedLoading,
          child: const LoadingIndicator(),
        ),
        // The shelf surfaces its failure rather than rendering as empty: here
        // an empty-looking screen would be a lie about the learner's data.
        error: (error, _) => Semantics(
          label: context.strings.savedLoadFailed,
          child: ErrorView(message: '$error'),
        ),
        // The shelf is titled whether or not it holds anything: the page's
        // large title is what names it at rest, and an empty shelf is still
        // the shelf.
        data: (groups) => groups.isEmpty
            ? _Empty(scrollPadding: scrollPadding)
            : _Shelf(
                scrollPadding: scrollPadding,
                groups: groups,
                // Unresolved entitlement reads as free — the offer is the
                // safe thing to show while the answer is still coming.
                isPlus: ref.watch(courseEntitlementProvider).value ?? false,
                onOpen: (item) => unawaited(_open(context, ref, item)),
              ),
      ),
    );
  }
}

/// The shelf with nothing on it — still titled, still the shelf.
class _Empty extends StatelessWidget {
  const _Empty({required this.scrollPadding});

  final EdgeInsets scrollPadding;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.gutter) +
          scrollPadding,
      children: [
        PageLargeTitle(context.strings.savedScreenTitle),
        const SavedEmptyView(),
      ],
    );
  }
}

class _Shelf extends StatelessWidget {
  const _Shelf({
    required this.scrollPadding,
    required this.groups,
    required this.isPlus,
    required this.onOpen,
  });

  /// The room the bar floating over this list leaves at the top.
  final EdgeInsets scrollPadding;

  final List<SavedGroup> groups;
  final bool isPlus;
  final void Function(SavedItem item) onOpen;

  @override
  Widget build(BuildContext context) {
    final count = savedShelfCount(groups);
    final countLine = savedCountLine(
      context.strings,
      count: count,
      isPlus: isPlus,
    );

    final mood = context.mood;

    // The scroll padding already clears the bar by the design's 108; a gutter
    // on top of it put the title a second gutter below the back chevron.
    return ListView(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.gutter) +
          scrollPadding +
          const EdgeInsets.only(bottom: _designBottomPad),
      children: [
        PageLargeTitle(context.strings.savedScreenTitle),
        if (countLine != null) ...[
          const SizedBox(height: AppSpacing.xs),
          // Mono at the design's `letterSpacing: 0.08em`, uppercase by rule
          // and announced as written.
          Semantics(
            label: countLine,
            excludeSemantics: true,
            child: Text(
              countLine.toUpperCase(),
              style: AppText.label(
                mood: mood,
                face: AppFace.mono,
                tracking: AppTracking.meta,
              ),
            ),
          ),
        ],
        // The offer belongs where the limit is felt.
        if (savedShelfIsFull(count: count, isPlus: isPlus)) ...[
          const SizedBox(height: AppSpacing.md),
          const SavedUpgradeRow(),
        ],
        const SizedBox(height: _groupsTop),
        for (final (index, group) in groups.indexed) ...[
          if (index > 0) const SizedBox(height: _groupGap),
          SavedGroupSection(
            group: group,
            onOpen: onOpen,
            // The deck is built from saved terms only, so the route belongs
            // on that group's header rather than over the whole page.
            trailing: group.kind == SavedKind.term
                ? const SavedStudyRow()
                : null,
          ),
        ],
      ],
    );
  }
}
