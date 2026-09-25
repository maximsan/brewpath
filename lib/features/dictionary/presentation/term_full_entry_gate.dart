import 'dart:async';

import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/features/monetization/domain/plus_gate_trigger.dart';
import 'package:brew_path/features/monetization/presentation/plus_gate_sheet.dart';
import 'package:brew_path/l10n/app_strings.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// Where the full entry would be, for a learner without the course.
///
/// The deep explanation, example, self-check and sources come with the course
/// (`docs/decisions.md` §12), so the entry stops at its short explanation and
/// this row stands in — saying what would open it, in accent because it is a
/// purchase lock rather than a progression one (ADR-0016).
class TermFullEntryGate extends StatelessWidget {
  /// Creates a [TermFullEntryGate] for the term called [term].
  const TermFullEntryGate({required this.term, super.key});

  /// The word itself, so the sheet names what was tapped.
  final String term;

  /// The design's `<LockMark size={13}/>` on a locked row.
  static const double _lockSize = 13;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    void openGate() =>
        unawaited(showPlusGate(context, LockedFullEntry(term: term)));

    return Semantics(
      button: true,
      label: context.strings.termEntryGateSemantics(
        context.strings.termOfDayReadFull,
        context.strings.termEntryComesWithCourse,
      ),
      onTap: openGate,
      excludeSemantics: true,
      child: InkWell(
        onTap: openGate,
        borderRadius: BorderRadius.circular(AppRadii.chrome),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.base),
          decoration: BoxDecoration(
            color: mood.surface,
            border: Border.all(color: mood.rule),
            borderRadius: BorderRadius.circular(AppRadii.chrome),
          ),
          child: Row(
            children: [
              IconMark(AppIcon.lock, size: _lockSize, color: mood.accent),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      context.strings.termOfDayReadFull,
                      style: AppText.body(mood: mood, face: AppFace.control),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      context.strings.termEntryComesWithCourse,
                      style: AppText.support(mood: mood, color: mood.inkMute),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              IconMark(AppIcon.chevron, color: mood.accent),
            ],
          ),
        ),
      ),
    );
  }
}
