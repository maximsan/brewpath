import 'package:brew_path/core/icons/disclosure_mark.dart';
import 'package:brew_path/core/widgets/disclosure.dart';
import 'package:brew_path/features/profile/domain/help_faq.dart';
import 'package:brew_path/features/profile/presentation/settings/settings_copy.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// One question, with its answer opening inline beneath it.
///
/// The mark is the design's plus turning into a cross rather than the caret
/// every other section takes: an answer is prose, not a count of things.
class HelpFaqRow extends StatelessWidget {
  /// Creates a row for [entry], open or closed, toggled by [onToggle].
  const HelpFaqRow({
    required this.entry,
    required this.isOpen,
    required this.onToggle,
    super.key,
  });

  /// The question and the answer under it.
  final HelpQuestion entry;

  /// Whether the answer is showing.
  final bool isOpen;

  /// Opens this row, and closes whichever was open.
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
      child: Disclosure(
        isOpen: isOpen,
        onToggle: onToggle,
        label: entry.question,
        glyph: DisclosureGlyph.plus,
        divider: true,
        // The design's `margin: '0 0 16px'` under the answer's paragraph.
        panelPadding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: _Answer(answer: entry.answer),
      ),
    );
  }
}

/// The answer, or the wait for the counts it is built from.
class _Answer extends StatelessWidget {
  const _Answer({required this.answer});

  final String? answer;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    if (answer case final text?) {
      return Text(
        text,
        style: AppText.support(mood: mood, color: mood.inkMute),
      );
    }

    return Semantics(
      label: SettingsCopy.faqLoadingLabel,
      child: Text(
        SettingsCopy.faqCounting,
        style: AppText.support(mood: mood, color: mood.inkMute),
      ),
    );
  }
}
