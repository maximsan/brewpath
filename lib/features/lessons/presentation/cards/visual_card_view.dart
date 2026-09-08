import 'package:brew_path/core/widgets/visual_guide_art.dart';
import 'package:brew_path/features/lessons/presentation/cards/card_boundary.dart';
import 'package:brew_path/features/lessons/presentation/cards/card_shell.dart';
import 'package:brew_path/features/saved/domain/saved_key.dart';
import 'package:brew_path/features/saved/presentation/saved_bookmark_button.dart';
import 'package:brew_path/shared/models/content/content_card.dart';
import 'package:brew_path/shared/repositories/visual_guide_repository.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The visual guide, inside the lesson that teaches it. Informational, so it
/// latches on arrival: there is nothing to answer, and it is the one rendered
/// kind that reports no success, which is why mastery cannot move when a lesson
/// gains one. The same drawing the Reference section and the guide's sheet use,
/// at the same size, so a learner meets the picture here and finds it unchanged
/// when they go back for it.
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

    // Only the bookmark's accessible name needs the guide record, and it falls
    // back to the card's own title — so a slow or failed read costs nothing a
    // learner sees. The drawing and the caption key off the card itself.
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
        _GuideBlock(subject: card.subject),
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

/// The drawing in its frame — deliberately headerless.
///
/// Both hosts, this card and the guide's own sheet, already state the kind and
/// the title directly above the frame, so an inner eyebrow and title repeated
/// the same two lines a second time.
class _GuideBlock extends StatelessWidget {
  const _GuideBlock({required this.subject});

  final String subject;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: mood.surface,
        border: Border.all(color: mood.rule),
        borderRadius: BorderRadius.circular(AppRadii.chrome),
      ),
      child: VisualGuideArt(subject: subject, size: VisualGuideArtSize.full),
    );
  }
}
