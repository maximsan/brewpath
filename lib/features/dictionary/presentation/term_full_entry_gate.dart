import 'dart:async';

import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/features/dictionary/presentation/term_entry_copy.dart';
import 'package:brew_path/features/monetization/domain/plus_gate_trigger.dart';
import 'package:brew_path/features/monetization/presentation/plus_gate_sheet.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// Where the full entry would be, for a learner without the course.
///
/// The deep explanation, the example, the self-check and the sources come
/// with the course (`docs/decisions.md` §12), so the entry stops at its short
/// explanation and this row stands in for the rest. It is the offer at the
/// moment the learner wants more — ADR-0005's *"targeted course pitch at peak
/// intent"* — and it says what would open it rather than only that it is
/// shut (ADR-0016).
///
/// **The label promises the full entry**, so the tap raises the gate; it must
/// never deliver the short explanation they are already reading.
///
/// One lock, drawn in accent, because it is a purchase lock and not a
/// progression one — ADR-0016's rule for every locked row.
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

    return Semantics(
      button: true,
      label: TermEntryCopy.gateSemantics,
      excludeSemantics: true,
      child: InkWell(
        onTap: () =>
            unawaited(showPlusGate(context, LockedFullEntry(term: term))),
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
                      TermEntryCopy.readFullEntry,
                      style: AppText.body(mood: mood, face: AppFace.control),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      TermEntryCopy.comesWithCourse,
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
