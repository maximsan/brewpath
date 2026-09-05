import 'dart:async';

import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/widgets/error_view.dart';
import 'package:brew_path/core/widgets/loading_indicator.dart';
import 'package:brew_path/core/widgets/page_large_title.dart';
import 'package:brew_path/core/widgets/sub_screen_scaffold.dart';
import 'package:brew_path/features/lessons/domain/lesson_destination.dart';
import 'package:brew_path/features/monetization/domain/course_entitlement.dart';
import 'package:brew_path/features/monetization/presentation/activity_start.dart';
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
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// How far the shelf scrolls before its bar arrives.
///
/// The design gives this one screen its own threshold — 72 where every other
/// page takes the hook's default 40.
const double _shelfScrollThreshold = 72;

/// Everything the learner has bookmarked, in three groups.
///
/// **Named "Saved", once.** The prototype calls this screen both "Saved" and
/// "Favorites"; "Favourites" was the word for the card-favouriting feature
/// deleted in `8fd7e6e`, and reusing it re-imports a confusion the design docs
/// keep having to correct. The stored field keeps its own name — renaming that
/// would be a schema change for a cosmetic reason.
class SavedScreen extends ConsumerWidget {
  /// Creates a [SavedScreen].
  const SavedScreen({super.key});

  /// What this screen is called, everywhere it is named.
  static const title = 'Saved';

  Future<void> _open(
    BuildContext context,
    WidgetRef ref,
    SavedItem item,
  ) async {
    switch (item.kind) {
      case SavedKind.term:
        unawaited(context.pushDictionaryTerm(item.id));
      case SavedKind.lesson:
        unawaited(context.pushActivity(lessonRun(item.id)));
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
      title: title,
      // The one screen the design gives its own threshold: the shelf waits
      // until 72 where every other page's bar arrives at 40.
      threshold: _shelfScrollThreshold,
      onBack: () => Navigator.of(context).maybePop(),
      body: (context, scrollPadding) => shelf.when(
        loading: () => Semantics(
          label: 'Loading your saved items',
          child: const LoadingIndicator(),
        ),
        // The shelf surfaces its failure rather than rendering as empty: here
        // an empty-looking screen would be a lie about the learner's data.
        error: (error, _) => Semantics(
          label: 'Your saved items could not be loaded',
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
      padding: const EdgeInsets.all(AppSpacing.gutter) + scrollPadding,
      children: const [
        PageLargeTitle(SavedScreen.title),
        SizedBox(height: AppSpacing.lg),
        SavedEmptyView(),
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

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.gutter) + scrollPadding,
      children: [
        const PageLargeTitle(SavedScreen.title),
        const SizedBox(height: AppSpacing.sm),
        Text(
          savedCountLine(count: count, isPlus: isPlus),
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: context.mood.inkMute),
        ),
        // The offer belongs where the limit is felt.
        if (savedShelfIsFull(count: count, isPlus: isPlus)) ...[
          const SizedBox(height: AppSpacing.md),
          const SavedUpgradeRow(),
        ],
        const SizedBox(height: AppSpacing.lg),
        for (final group in groups) ...[
          SavedGroupSection(group: group, onOpen: onOpen),
          if (group.kind == SavedKind.term) ...[
            const SizedBox(height: AppSpacing.sm),
            const SavedStudyRow(),
          ],
          const SizedBox(height: AppSpacing.lg),
        ],
      ],
    );
  }
}
