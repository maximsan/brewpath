import 'dart:async';

import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/features/dictionary/presentation/vocab/vocab_copy.dart';
import 'package:brew_path/features/dictionary/presentation/vocab/vocab_mark.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The dictionary drills, leading the Learn tab's **Games** group.
///
/// ADR-0004 rules that the practice section lists all four practice types, and
/// that these rows lead the Games group as its first entries rather than
/// sitting beside it — one container for everything playable.
///
/// **Free, with no lock treatment, always visible.** The drills are content-
/// scoped, never feature-gated: a free learner plays them over the terms their
/// lessons reached, which is a smaller pool rather than a locked door. A lock
/// mark here would say the opposite of what is true, and these are a free
/// learner's cheapest streak path.
///
/// One row today. Flashcards (#97) is the second, and adds itself here.
class PracticeDrillsWidget extends StatelessWidget {
  /// Creates a [PracticeDrillsWidget].
  const PracticeDrillsWidget({super.key});

  @override
  Widget build(BuildContext context) => const Card(
    margin: EdgeInsets.zero,
    child: _VocabRow(),
  );
}

class _VocabRow extends StatelessWidget {
  const _VocabRow();

  /// The mark's drawn size, matching the kind glyphs it sits above.
  static const double _markSize = 20;

  /// What the row promises about cost. Stated because the group it leads is
  /// full of rows that are not free.
  static const String _free = 'Free';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;

    return Semantics(
      button: true,
      label: '${VocabCopy.title}. ${VocabCopy.rowSubtitle}. $_free.',
      excludeSemantics: true,
      child: InkWell(
        onTap: () => unawaited(
          context.pushNamed(AppRoutes.vocabGame.name),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              VocabMark(
                size: _markSize,
                color: mood.inkMute,
                accent: mood.accent,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      VocabCopy.rowSubtitle.toUpperCase(),
                      // The eyebrow takes the meta treatment every practice
                      // row's does — 0.08em, not the section's smallcaps.
                      style: AppText.label(
                        color: mood.inkMute,
                        face: AppFace.mono,
                        tracking: AppTracking.meta,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      VocabCopy.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: mood.ink,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                _free.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: mood.inkMute,
                ),
              ),
              IconMark(AppIcon.chevron, color: mood.inkMute),
            ],
          ),
        ),
      ),
    );
  }
}
