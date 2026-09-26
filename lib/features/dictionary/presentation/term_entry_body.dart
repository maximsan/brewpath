import 'dart:async';

import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/utils/object_position.dart';
import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/features/dictionary/domain/dictionary_derivations.dart';
import 'package:brew_path/features/dictionary/domain/dictionary_providers.dart';
import 'package:brew_path/features/dictionary/presentation/dictionary_status_style.dart';
import 'package:brew_path/features/dictionary/presentation/speak_button.dart';
import 'package:brew_path/features/dictionary/presentation/term_full_entry_gate.dart';
import 'package:brew_path/features/dictionary/presentation/term_self_check.dart';
import 'package:brew_path/features/dictionary/presentation/term_sources_section.dart';
import 'package:brew_path/features/lessons/presentation/replay_confirm_sheet.dart';
import 'package:brew_path/features/monetization/domain/free_tier.dart';
import 'package:brew_path/l10n/app_strings.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    this.leadWithShort = true,
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

  /// Whether the short explanation opens the entry even when the deep one
  /// follows. The peek keeps it; the full page leads with the deep text.
  final bool leadWithShort;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mood = context.mood;
    final text = Theme.of(context).textTheme;
    final status = dictionaryStatusOf(term, view.completedLessonIds);
    // Resolved up front: an id with no term behind it — a reference term on
    // a free learner's shelf, or content that moved — is dropped, and a block
    // whose every chip dropped is not drawn at all.
    final related = [for (final id in term.relatedIds) ?view.termById(id)];
    final showsDeep = view.hasCourse && term.deepExplanation != null;
    // The short line is the free learner's whole entry and the peek's opener;
    // a full page with a deep explanation starts on that instead.
    final leadsWithShort = leadWithShort || !showsDeep;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (term.pronunciation != null)
          SpeakButton(word: term.term, respelling: term.pronunciation!),
        const SizedBox(height: AppSpacing.xs),
        if (leadsWithShort)
          Text(term.shortExplanation, style: AppText.heading(mood: mood)),
        // The gate stands only where something stands behind it: a term the
        // course adds nothing to has no full entry to promise.
        if (!view.hasCourse && term.hasFullEntry) ...[
          const SizedBox(height: AppSpacing.lg),
          _Block(
            label: context.strings.termEntryFullExplanation,
            accent: true,
            child: TermFullEntryGate(term: term.term),
          ),
        ],
        if (view.hasCourse) ...[
          if (showsDeep) ...[
            if (leadsWithShort) const SizedBox(height: AppSpacing.md),
            Text(
              term.deepExplanation!,
              style: text.bodyMedium?.copyWith(color: mood.ink),
            ),
          ],
        ],
        if (onRelatedTap != null && related.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          _Block(
            label: context.strings.termRelated,
            child: _RelatedChips(related: related, onTap: onRelatedTap!),
          ),
        ],
        if (view.hasCourse && term.check != null) ...[
          const SizedBox(height: AppSpacing.lg),
          _Card(
            child: _Block(
              label: context.strings.termKnowledgeCheck,
              child: TermSelfCheck(check: term.check!),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        Divider(height: 1, thickness: 1, color: mood.rule),
        const SizedBox(height: AppSpacing.lg),
        _PathBlock(view: view, status: status, lessonId: term.lessonId),
        if (view.hasCourse && term.sources.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          TermSourcesSection(sources: term.sources),
        ],
      ],
    );
  }
}

/// Related terms as outlined pills, shown by name rather than by id.
///
/// Already resolved against the learner's shelf, so every pill here opens
/// onto a term they can have.
class _RelatedChips extends StatelessWidget {
  const _RelatedChips({required this.related, required this.onTap});

  /// The design's `padding: 10px 18px` inside a pill.
  static const EdgeInsets _pillPadding = EdgeInsets.symmetric(
    horizontal: 18,
    vertical: 10,
  );

  final List<DictionaryTerm> related;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        for (final term in related)
          Material(
            color: Colors.transparent,
            shape: StadiumBorder(side: BorderSide(color: mood.rule)),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => onTap(term.id),
              child: Padding(
                padding: _pillPadding,
                child: Text(
                  term.term,
                  style: AppText.body(mood: mood, face: AppFace.control),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// The page's one filled container — the design's `radius 14` card on a
/// `1px var(--rule)` border, given to the block you act on from inside.
class _Card extends StatelessWidget {
  const _Card({required this.child});

  /// The design's `padding: 18` inside the card.
  static const double _pad = 18;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(_pad),
      decoration: BoxDecoration(
        color: mood.surface,
        borderRadius: BorderRadius.circular(AppRadii.chrome),
        border: Border.all(color: mood.rule),
      ),
      child: child,
    );
  }
}

/// Where on the path this term is taught — or that nothing teaches it.
///
/// The lesson is a row you can open: its module's picture, its title, and a
/// chevron when the learner may play it or a lock when the course has not
/// been bought.
class _PathBlock extends ConsumerWidget {
  const _PathBlock({
    required this.view,
    required this.status,
    required this.lessonId,
  });

  /// The design's `48` square thumbnail at `borderRadius: 10`, then `gap: 14`.
  static const double _art = 48;
  static const double _artGap = 14;

  final DictionaryView view;
  final DictionaryStatus status;
  final String? lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mood = context.mood;
    final body = Theme.of(context).textTheme.bodyMedium;

    if (status == DictionaryStatus.reference) {
      return _Block(
        label: status.pathLabel(context.strings),
        child: Text(
          context.strings.termReferenceNote,
          style: body?.copyWith(color: mood.inkMute),
        ),
      );
    }

    final id = lessonId;
    final place = ref.watch(lessonPlaceProvider(id)).asData?.value;
    final accessible = id != null && (view.hasCourse || isLessonFree(id));
    // Until the place resolves there is nothing honest to show — an id is not
    // an answer, so the row simply has no text yet.
    final title = place?.title ?? '';
    final open = id == null
        ? null
        : () => unawaited(context.pushLessonAskingReview(id));

    return _Block(
      label: status.pathLabel(context.strings),
      child: Semantics(
        // Only a button once there is an id to open: before the place
        // resolves there is nothing to press, and saying otherwise is the
        // announcement this row is being fixed for (#487).
        button: open != null,
        label: accessible
            ? context.strings.termLessonOpens(title)
            : context.strings.termLessonLocked(title),
        onTap: open,
        excludeSemantics: true,
        child: InkWell(
          onTap: open,
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.inner),
                child: SizedBox.square(
                  dimension: _art,
                  child: _ModuleArt(art: place?.art, artPos: place?.artPos),
                ),
              ),
              const SizedBox(width: _artGap),
              Expanded(
                child: Text(
                  title,
                  style: AppText.body(mood: mood, face: AppFace.control),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              IconMark(
                accessible ? AppIcon.chevron : AppIcon.lock,
                color: accessible ? mood.accent : mood.inkMute,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A module's picture cropped to a square, or the raised surface where a
/// module has none or the bundle cannot decode it — never a broken image.
class _ModuleArt extends StatelessWidget {
  const _ModuleArt({required this.art, required this.artPos});

  final String? art;
  final String? artPos;

  @override
  Widget build(BuildContext context) {
    final fallback = ColoredBox(color: context.mood.surface2);
    final asset = art;
    if (asset == null) return fallback;
    return Image.asset(
      asset,
      fit: BoxFit.cover,
      alignment: alignmentFromObjectPosition(artPos),
      errorBuilder: (_, _, _) => fallback,
    );
  }
}

/// A titled block: a smallcaps label over its content.
class _Block extends StatelessWidget {
  const _Block({required this.label, required this.child, this.accent = false});

  final String label;
  final Widget child;

  /// Whether the label takes the accent: the gated expansion does, because a
  /// purchase lock is drawn in accent (ADR-0016).
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
