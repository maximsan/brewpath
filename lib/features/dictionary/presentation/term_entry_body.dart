import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/features/dictionary/domain/dictionary_derivations.dart';
import 'package:brew_path/features/dictionary/presentation/term_self_check.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// What a reference-only term says instead of naming a lesson.
///
/// The dash means *not on the path at all* — offering "you'll learn it in…"
/// here would promise a lesson the course does not have.
const _referenceNote =
    "No lesson covers this one — it's here for when you meet it on a bag or a "
    'menu.';

/// A term's entry: pronunciation, explanations, example, self-check, related
/// terms, sources, and where on the path it sits.
///
/// Shared by the full screen and the peek sheet. A term carrying only a short
/// explanation simply renders fewer blocks — a quarter of the dictionary is
/// short-only, and that is not a gap to advertise.
class TermEntryBody extends StatelessWidget {
  /// Creates a [TermEntryBody].
  const TermEntryBody({
    required this.term,
    required this.status,
    required this.lessonTitle,
    this.onRelatedTap,
    super.key,
  });

  /// The term being read.
  final DictionaryTerm term;

  /// [term]'s status for this learner, already derived.
  final DictionaryStatus status;

  /// The title of the lesson that teaches it, when one does.
  final String? lessonTitle;

  /// Called with a related term's id. When null, related chips are hidden —
  /// the peek sheet has nowhere to push them.
  final ValueChanged<String>? onRelatedTap;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (term.pronunciation != null)
          Text(
            term.pronunciation!,
            style: text.bodySmall?.copyWith(color: mood.inkMute),
          ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          term.shortExplanation,
          style: text.bodyLarge?.copyWith(color: mood.ink),
        ),
        if (term.deepExplanation != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            term.deepExplanation!,
            style: text.bodyMedium?.copyWith(color: mood.ink),
          ),
        ],
        if (term.example != null) ...[
          const SizedBox(height: AppSpacing.md),
          _Block(
            label: 'In use',
            child: Text(
              term.example!,
              style: text.bodyMedium?.copyWith(color: mood.inkMute),
            ),
          ),
        ],
        if (term.check != null) ...[
          const SizedBox(height: AppSpacing.lg),
          _Block(
            label: 'Check yourself',
            child: TermSelfCheck(check: term.check!),
          ),
        ],
        if (onRelatedTap != null && term.relatedIds.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          _Block(
            label: 'Related',
            child: Wrap(
              spacing: AppSpacing.xs,
              children: [
                for (final id in term.relatedIds)
                  ActionChip(
                    label: Text(id),
                    onPressed: () => onRelatedTap!(id),
                  ),
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        _PathBlock(
          status: status,
          lessonTitle: lessonTitle,
          lessonId: term.lessonId,
        ),
        if (term.sources.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          _Block(
            label: 'Sources',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final source in term.sources)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
                    child: Text(
                      source.label,
                      style: text.bodySmall?.copyWith(color: mood.inkMute),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Where on the path this term is taught — or that nothing teaches it.
class _PathBlock extends StatelessWidget {
  const _PathBlock({
    required this.status,
    required this.lessonTitle,
    required this.lessonId,
  });

  final DictionaryStatus status;
  final String? lessonTitle;
  final String? lessonId;

  String get _label => switch (status) {
    DictionaryStatus.learned => 'Where you learned it',
    DictionaryStatus.toLearn => "Where you'll learn it",
    DictionaryStatus.reference => 'Not on the path',
  };

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final body = Theme.of(context).textTheme.bodyMedium;

    if (status == DictionaryStatus.reference) {
      return _Block(
        label: _label,
        child: Text(
          _referenceNote,
          style: body?.copyWith(color: mood.inkMute),
        ),
      );
    }

    return _Block(
      label: _label,
      child: TextButton(
        onPressed: () => context.pushNamed(
          AppRoutes.lesson.name,
          pathParameters: {'lessonId': lessonId!},
        ),
        child: Text(lessonTitle ?? lessonId!),
      ),
    );
  }
}

/// A titled block: a smallcaps label over its content.
class _Block extends StatelessWidget {
  const _Block({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: context.mood.inkMute, letterSpacing: 1),
        ),
        const SizedBox(height: AppSpacing.xs),
        child,
      ],
    );
  }
}
