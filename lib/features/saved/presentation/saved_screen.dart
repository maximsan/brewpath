import 'dart:async';

import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/widgets/error_view.dart';
import 'package:brew_path/core/widgets/loading_indicator.dart';
import 'package:brew_path/features/path/domain/visual_guide_providers.dart';
import 'package:brew_path/features/path/presentation/visual_guide_sheet.dart';
import 'package:brew_path/features/saved/domain/saved_key.dart';
import 'package:brew_path/features/saved/domain/saved_providers.dart';
import 'package:brew_path/features/saved/domain/saved_shelf.dart';
import 'package:brew_path/features/saved/presentation/saved_empty_view.dart';
import 'package:brew_path/features/saved/presentation/saved_group_section.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

  void _open(BuildContext context, WidgetRef ref, SavedItem item) {
    switch (item.kind) {
      case SavedKind.term:
        unawaited(context.pushDictionaryTerm(item.id));
      case SavedKind.lesson:
        unawaited(
          context.pushNamed(
            AppRoutes.lesson.name,
            pathParameters: {'lessonId': item.id},
          ),
        );
      case SavedKind.guide:
        final guide = ref.read(earnedGuideForProvider(item.id)).value;
        if (guide != null) unawaited(showVisualGuideSheet(context, guide));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shelf = ref.watch(savedShelfProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(title)),
      body: shelf.when(
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
        data: (groups) => groups.isEmpty
            ? const SavedEmptyView()
            : _Shelf(
                groups: groups,
                onOpen: (item) => _open(context, ref, item),
              ),
      ),
    );
  }
}

class _Shelf extends StatelessWidget {
  const _Shelf({required this.groups, required this.onOpen});

  final List<SavedGroup> groups;
  final void Function(SavedItem item) onOpen;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.gutter),
      children: [
        Text(
          _countLine(savedShelfCount(groups)),
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: context.mood.inkMute),
        ),
        const SizedBox(height: AppSpacing.lg),
        for (final group in groups) ...[
          SavedGroupSection(group: group, onOpen: onOpen),
          const SizedBox(height: AppSpacing.lg),
        ],
      ],
    );
  }
}

/// What the count line says. The tiered form — a fraction against the free
/// cap — arrives with the cap itself.
String _countLine(int count) => '${savedItemCount(count)} to revisit';
