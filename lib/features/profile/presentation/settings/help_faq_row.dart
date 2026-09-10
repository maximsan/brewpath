import 'package:brew_path/core/icons/caret_mark.dart';
import 'package:brew_path/features/profile/domain/help_faq.dart';
import 'package:brew_path/features/profile/presentation/settings/settings_copy.dart';
import 'package:brew_path/shared/theme/app_motion.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// One question, with its answer opening inline beneath it.
///
/// The mark is [CaretMark], the design system's one accordion glyph, not the
/// plus the design's own FAQ screen hand-rolls (#531).
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
    final mood = context.mood;

    return Semantics(
      button: true,
      expanded: isOpen,
      child: InkWell(
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.question,
                        style: AppText.body(mood: mood),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    CaretMark(open: isOpen, color: mood.inkMute),
                  ],
                ),
              ),
              _Answer(isOpen: isOpen, answer: entry.answer),
              Divider(height: 0, thickness: 1, color: mood.rule),
            ],
          ),
        ),
      ),
    );
  }
}

/// The answer, revealed without an animator when motion is reduced.
///
/// ⚠️ Reduced motion **drops** `AnimatedSize` rather than zeroing it: handed
/// `Duration.zero` it re-dirties itself inside its own `performLayout`, which
/// the framework asserts on — the defect a sweep test now forbids.
class _Answer extends StatelessWidget {
  const _Answer({required this.isOpen, required this.answer});

  final bool isOpen;
  final String? answer;

  @override
  Widget build(BuildContext context) {
    final shown = isOpen
        ? Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _Body(answer: answer),
          )
        : const SizedBox(width: double.infinity);

    if (MediaQuery.disableAnimationsOf(context)) return shown;

    return AnimatedSize(
      duration: AppMotion.expand,
      curve: Curves.easeOut,
      alignment: Alignment.topCenter,
      child: shown,
    );
  }
}

/// The answer, or the wait for the counts it is built from.
class _Body extends StatelessWidget {
  const _Body({required this.answer});

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
