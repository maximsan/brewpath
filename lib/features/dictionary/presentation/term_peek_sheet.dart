import 'dart:async';

import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/widgets/app_sheet.dart';
import 'package:brew_path/features/dictionary/domain/dictionary_providers.dart';
import 'package:brew_path/features/dictionary/presentation/term_entry_body.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Opens [termId] in a sheet over whatever the learner is already looking at.
///
/// Checking a word should not cost the screen you were on — so this is a sheet
/// rather than a push, and it offers a way through to the full entry.
///
/// The term is resolved here rather than inside the sheet because the shared
/// primitive takes the title up front — it is the sheet's heading and its
/// accessible name, and both have to exist before the route opens.
Future<void> showTermPeekSheet(BuildContext context, String termId) {
  final view = ProviderScope.containerOf(
    context,
    listen: false,
  ).read(dictionaryViewProvider).asData?.value;

  return showAppSheet<void>(
    context: context,
    title: view?.termById(termId)?.term ?? termId,
    builder: (_) => TermPeekSheet(termId: termId),
  );
}

/// One term, compressed into a sheet.
class TermPeekSheet extends ConsumerWidget {
  /// Creates a [TermPeekSheet].
  const TermPeekSheet({required this.termId, super.key});

  /// The term to peek at.
  final String termId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(dictionaryViewProvider).asData?.value;
    final term = view?.termById(termId);
    if (view == null || term == null) return const SizedBox.shrink();

    // Content only: the heading, the height cap, the scrolling and the insets
    // are the sheet primitive's, so every sheet wears them the same way.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TermEntryBody(view: view, term: term),
        const SizedBox(height: AppSpacing.md),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              final opener = context.pushDictionaryTerm;
              Navigator.of(context).pop();
              unawaited(opener(termId));
            },
            child: const Text('Read the full entry'),
          ),
        ),
      ],
    );
  }
}
