import 'package:brew_path/core/widgets/primary_button.dart';
import 'package:brew_path/features/dictionary/domain/vocab_setup.dart';
import 'package:brew_path/l10n/app_strings.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// What the drill shows when the learner's pool cannot fill a question.
///
/// It never pads from the full glossary, which would hand a free learner the
/// premium term names the tier rule withholds (#57), so it declines and points
/// at the fix. Unreachable on the shipped banks and kept because the pool is
/// derived: narrowing the free lesson list makes it reachable with no edit.
class VocabTeachingView extends StatelessWidget {
  /// Creates a [VocabTeachingView].
  const VocabTeachingView({required this.onDone, super.key});

  /// Leaves the drill, back to where lessons are.
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return SafeArea(
      child: Semantics(
        label:
            '${context.strings.vocabTeachingTitle}. '
            '${context.strings.vocabTeachingBody(vocabMinimumPool)}',
        excludeSemantics: true,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.strings.vocabTitle,
                style: AppText.display(mood: mood),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                context.strings.vocabTeachingTitle,
                style: AppText.heading(mood: mood),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                context.strings.vocabTeachingBody(vocabMinimumPool),
                style: AppText.body(mood: mood),
              ),
              const Spacer(),
              PrimaryButton(
                label: context.strings.vocabTeachingAction,
                onPressed: onDone,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
