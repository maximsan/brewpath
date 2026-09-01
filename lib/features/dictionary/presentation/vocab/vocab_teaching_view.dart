import 'package:brew_path/core/widgets/primary_button.dart';
import 'package:brew_path/features/dictionary/presentation/vocab/vocab_copy.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// What the drill shows when the learner's pool cannot fill a question.
///
/// It never pads from the full glossary: that would hand a free learner the
/// premium term names the tier rule exists to withhold (#57). So the drill
/// declines and points at what would fix it.
///
/// Unreachable on the shipped banks, and kept because the pool is derived —
/// narrowing the free lesson list makes it reachable with no edit here.
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
        label: '${VocabCopy.teachingTitle}. ${VocabCopy.teachingBody}',
        excludeSemantics: true,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(VocabCopy.title, style: AppText.display(mood: mood)),
              const SizedBox(height: AppSpacing.lg),
              Text(
                VocabCopy.teachingTitle,
                style: AppText.heading(mood: mood),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(VocabCopy.teachingBody, style: AppText.body(mood: mood)),
              const Spacer(),
              PrimaryButton(
                label: VocabCopy.teachingAction,
                onPressed: onDone,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
