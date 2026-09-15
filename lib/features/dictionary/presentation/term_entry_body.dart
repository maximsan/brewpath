import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/features/dictionary/domain/dictionary_derivations.dart';
import 'package:brew_path/features/dictionary/domain/dictionary_providers.dart';
import 'package:brew_path/features/dictionary/presentation/dictionary_status_style.dart';
import 'package:brew_path/features/dictionary/presentation/speak_button.dart';
import 'package:brew_path/features/dictionary/presentation/term_entry_copy.dart';
import 'package:brew_path/features/dictionary/presentation/term_full_entry_gate.dart';
import 'package:brew_path/features/dictionary/presentation/term_self_check.dart';
import 'package:brew_path/features/dictionary/presentation/term_sources_section.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// What a reference-only term says instead of naming a lesson.
///
/// The dash means *not on the path at all* — offering "you'll learn it in…"
/// here would promise a lesson the course does not have.
const _referenceNote =
    "No lesson covers this one — it's here for when you meet it on a bag or a "
    'menu.';

/// A term's entry, shared by the full screen and the peek sheet.
///
/// What it renders depends on the tier (`docs/decisions.md` §12): without the
/// course the entry stops at the short explanation and a gated row stands
/// where the rest would be, so none of it is built and none can leak.
/// Pronunciation, related terms and the path block stay on both sides.
class TermEntryBody extends ConsumerWidget {
  /// Creates a [TermEntryBody].
  const TermEntryBody({
    required this.view,
    required this.term,
    this.onRelatedTap,
    super.key,
  });

  /// The dictionary and the learner's progress, for resolving status and the
  /// display names of related terms.
  final DictionaryView view;

  /// The term being read.
  final DictionaryTerm term;

  /// Called with a related term's id. When null, related chips are hidden —
  /// the peek sheet does not stack peeks on itself.
  final ValueChanged<String>? onRelatedTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mood = context.mood;
    final text = Theme.of(context).textTheme;
    final status = dictionaryStatusOf(term, view.completedLessonIds);
    // Resolved up front: an id with no term behind it — a reference term on
    // a free learner's shelf, or content that moved — is dropped, and a block
    // whose every chip dropped is not drawn at all.
    final related = [for (final id in term.relatedIds) ?view.termById(id)];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (term.pronunciation != null)
          SpeakButton(word: term.term, respelling: term.pronunciation!),
        const SizedBox(height: AppSpacing.xs),
        // The **display** face at the heading rung, not
        // body copy: the short explanation is the entry's answer, and setting
        // it in the reading face made it a first paragraph of the deep one.
        Text(term.shortExplanation, style: AppText.heading(mood: mood)),
        // The gate stands only where something stands behind it: a term the
        // course adds nothing to has no full entry to promise.
        if (!view.hasCourse && term.hasFullEntry) ...[
          const SizedBox(height: AppSpacing.lg),
          _Block(
            label: TermEntryCopy.fullExplanation,
            accent: true,
            child: TermFullEntryGate(term: term.term),
          ),
        ],
        if (view.hasCourse) ...[
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
              label: 'In practice',
              accent: true,
              child: Text(
                term.example!,
                style: text.bodyMedium?.copyWith(color: mood.inkMute),
              ),
            ),
          ],
          if (term.check != null) ...[
            const SizedBox(height: AppSpacing.lg),
            _Block(
              label: 'Knowledge check',
              child: TermSelfCheck(check: term.check!),
            ),
          ],
        ],
        if (onRelatedTap != null && related.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          _Block(
            label: 'Related terms',
            child: _RelatedChips(related: related, onTap: onRelatedTap!),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        _PathBlock(status: status, lessonId: term.lessonId),
        if (view.hasCourse && term.sources.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          TermSourcesSection(sources: term.sources),
        ],
      ],
    );
  }
}

/// Related terms, shown by name rather than by id.
///
/// A learner reading *Cold Brew* should see *Gooseneck kettle*, not
/// `gooseneck`. Already resolved against the learner's shelf, so every chip
/// here opens onto a term they can have.
class _RelatedChips extends StatelessWidget {
  const _RelatedChips({required this.related, required this.onTap});

  final List<DictionaryTerm> related;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      children: [
        for (final term in related)
          ActionChip(label: Text(term.term), onPressed: () => onTap(term.id)),
      ],
    );
  }
}

/// Where on the path this term is taught — or that nothing teaches it.
class _PathBlock extends ConsumerWidget {
  const _PathBlock({required this.status, required this.lessonId});

  final DictionaryStatus status;
  final String? lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mood = context.mood;
    final body = Theme.of(context).textTheme.bodyMedium;

    if (status == DictionaryStatus.reference) {
      return _Block(
        label: status.pathLabel,
        child: Text(_referenceNote, style: body?.copyWith(color: mood.inkMute)),
      );
    }

    final title = ref.watch(lessonTitleProvider(lessonId)).asData?.value;
    return _Block(
      label: status.pathLabel,
      // Until the title resolves there is nothing honest to show — an id is
      // not an answer, so the row simply has no text yet.
      child: Text(title ?? '', style: body?.copyWith(color: mood.ink)),
    );
  }
}

/// A titled block: a smallcaps label over its content.
class _Block extends StatelessWidget {
  const _Block({required this.label, required this.child, this.accent = false});

  final String label;
  final Widget child;

  /// Whether the label takes the accent. `IN PRACTICE` does — it heads the
  /// one block that is an example rather than more explanation — and so does
  /// the gated expansion, because a purchase lock is drawn in accent
  /// (ADR-0016).
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SmallcapsLabel(label, color: accent ? context.mood.accentText : null),
        const SizedBox(height: AppSpacing.xs),
        child,
      ],
    );
  }
}
