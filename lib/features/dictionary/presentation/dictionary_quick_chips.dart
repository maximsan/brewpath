import 'dart:async';

import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/features/dictionary/presentation/vocab/vocab_copy.dart';
import 'package:brew_path/features/dictionary/presentation/vocab/vocab_mark.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The drill row on Dictionary home — one slim chip per practice surface the
/// dictionary owns.
///
/// **One chip today.** The design's row carries two, Flashcards beside this
/// one; that surface is #97 and adds its chip here when it lands rather than
/// building a second row. The row is a `Row` of expanded chips for that
/// reason — a second chip costs a line, not a layout.
class DictionaryQuickChips extends StatelessWidget {
  /// Creates a [DictionaryQuickChips].
  const DictionaryQuickChips({super.key});

  @override
  Widget build(BuildContext context) => const Row(
    children: [Expanded(child: _VocabChip())],
  );
}

class _VocabChip extends StatelessWidget {
  const _VocabChip();

  /// The mark's drawn size in a chip, from the design's own row.
  static const double _markSize = 18;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Semantics(
      button: true,
      label: VocabCopy.title,
      hint: VocabCopy.rowSubtitle,
      excludeSemantics: true,
      child: Material(
        color: mood.surface,
        borderRadius: BorderRadius.circular(AppRadii.chrome),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.chrome),
          onTap: () => unawaited(
            context.pushNamed(AppRoutes.vocabGame.name),
          ),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: mood.rule),
              borderRadius: BorderRadius.circular(AppRadii.chrome),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                VocabMark(
                  size: _markSize,
                  color: mood.inkMute,
                  accent: mood.accent,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    VocabCopy.title,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.support(mood: mood),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
