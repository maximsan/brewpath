import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/core/widgets/visual_guide_art.dart';
import 'package:brew_path/features/lessons/presentation/cards/card_boundary.dart';
import 'package:brew_path/features/lessons/presentation/cards/card_shell.dart';
import 'package:brew_path/features/saved/domain/saved_key.dart';
import 'package:brew_path/features/saved/presentation/saved_bookmark_button.dart';
import 'package:brew_path/shared/models/content/content_card.dart';
import 'package:brew_path/shared/models/content/visual_guide.dart';
import 'package:brew_path/shared/repositories/visual_guide_repository.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The visual guide, inside the lesson that teaches it.
///
/// **Informational, so it latches on arrival**: there is nothing to answer, it
/// is never graded, and Continue is live from the first frame. It is the one
/// rendered kind that reports no success, which is why mastery cannot move
/// when a lesson gains one.
///
/// The same drawing the Reference section and the guide's sheet use, at the
/// same size — a learner meets the picture here first and finds it unchanged
/// when they go back for it later.
class VisualCardView extends ConsumerWidget {
  /// Creates a [VisualCardView].
  const VisualCardView({
    required this.card,
    required this.onContinue,
    super.key,
  });

  /// The card's content.
  final VisualCard card;

  /// Fired when the learner moves on.
  final CardAdvance onContinue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mood = context.mood;
    final text = Theme.of(context).textTheme;

    // Only the framed block's own header needs the guide record, so a slow or
    // failed read costs that header and nothing else: the drawing, the
    // caption and the bookmark all key off the card itself.
    final guide = ref.watch(visualGuideForSubjectProvider(card.subject));

    final caption = Text(
      card.caption,
      style: text.bodyMedium?.copyWith(
        // Above the drawing it introduces it, below it comments on it — so
        // the top position speaks at full strength and the bottom one does
        // not compete with the picture it follows.
        color: (card.captionTop ?? false) ? mood.ink : mood.inkMute,
      ),
    );

    return CardShell(
      latched: true,
      onContinue: onContinue,
      label: card.label,
      title: card.title,
      children: [
        if (card.captionTop ?? false) ...[
          caption,
          const SizedBox(height: AppSpacing.md),
        ],
        _GuideBlock(
          subject: card.subject,
          // `mergeHeader` is authored on exactly the card whose own title
          // already says what the block's header would: showing both is the
          // duplication the flag exists to remove.
          guide: (card.mergeHeader ?? false) ? null : guide.asData?.value,
        ),
        const SizedBox(height: AppSpacing.sm),
        Align(
          alignment: Alignment.centerLeft,
          child: SavedBookmarkButton(
            // The guide's **subject**, never its id — the same key the sheet
            // writes, so saving here and saving there are one act.
            savedKey: formatSavedKey(SavedKind.guide, card.subject),
            label: guide.asData?.value?.title ?? card.title,
          ),
        ),
        if (!(card.captionTop ?? false)) ...[
          const SizedBox(height: AppSpacing.xs),
          caption,
        ],
      ],
    );
  }
}

/// The drawing in its frame, with the guide's own header above it unless the
/// card has asked for the two to merge.
class _GuideBlock extends StatelessWidget {
  const _GuideBlock({required this.subject, required this.guide});

  final String subject;

  /// The guide whose name the block announces, or null when the card's own
  /// header already carries it.
  final VisualGuide? guide;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final text = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: mood.surface,
        border: Border.all(color: mood.rule),
        borderRadius: BorderRadius.circular(AppRadii.chrome),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (guide case final guide?) ...[
            SmallcapsLabel(guide.label, color: mood.accentText),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              guide.title,
              style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          VisualGuideArt(subject: subject, size: VisualGuideArtSize.full),
        ],
      ),
    );
  }
}
