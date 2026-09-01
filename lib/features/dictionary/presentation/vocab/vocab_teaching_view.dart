import 'package:brew_path/core/widgets/primary_button.dart';
import 'package:brew_path/features/dictionary/presentation/vocab/vocab_copy.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// What the drill shows when the learner's pool cannot fill a question.
///
/// **It never pads from the full glossary.** A four-option question built from
/// terms the course has not taught is an exam for a class the learner could
/// not attend — and for a free learner it would also hand over the premium
/// term names the tier rule exists to withhold (#57). So the drill declines
/// and points at the thing that would actually fix it.
///
/// Unreachable on the shipped banks, where even the free tier's lessons
/// mention well over four terms. It is here because the pool is *derived* —
/// widen or narrow the free lesson list and this becomes reachable without
/// anyone editing this screen.
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
