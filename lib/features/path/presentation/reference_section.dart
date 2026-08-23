import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/features/path/domain/visual_guide_providers.dart';
import 'package:brew_path/features/path/domain/visual_guide_shelf.dart';
import 'package:brew_path/features/path/presentation/visual_guide_art.dart';
import 'package:brew_path/features/path/presentation/visual_guide_sheet.dart';
import 'package:brew_path/shared/models/content/visual_guide.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Copy, ported as authored.
const _title = 'Reference';
const _openSubtitle = 'Visual guides from your lessons';
const _lockedSubtitle = 'Visual guides unlock as lessons teach them';
String _remainingLine(int remaining) => '$remaining more unlock as you learn';

/// The last thing on Path: the illustrated references a learner has earned.
///
/// Styled as a section rather than a boxed card, because Path is editorial and
/// a boxed shelf reads as another screen's component.
///
/// **Locked guides are not drawn** — they never leave [visualGuideShelf], so
/// this cannot render one by mistake. What it shows instead is how many are
/// still to come, which turns the absence into a promise rather than a wall of
/// grey tiles at the moment a learner owns one of eight.
class ReferenceSection extends ConsumerStatefulWidget {
  /// Creates a [ReferenceSection].
  const ReferenceSection({super.key});

  @override
  ConsumerState<ReferenceSection> createState() => _ReferenceSectionState();
}

class _ReferenceSectionState extends ConsumerState<ReferenceSection> {
  /// Collapsed by default: a long Path should not end in a list nobody asked
  /// for. Held here so opening it once is enough to look at two guides.
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    final shelf = ref.watch(visualGuideShelfForProvider).asData?.value;
    // Nothing honest to show while it loads, and nothing to say if the bank is
    // empty — the section simply is not there.
    if (shelf == null) return const SizedBox.shrink();
    if (shelf.earned.isEmpty && shelf.remaining == 0) {
      return const SizedBox.shrink();
    }

    final isOpen = _isOpen && !shelf.isLocked;

    return Semantics(
      container: true,
      label: shelf.isLocked
          ? '$_title, locked. $_lockedSubtitle'
          : '$_title, ${shelf.earned.length} guides',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Heading(
            isLocked: shelf.isLocked,
            isOpen: isOpen,
            // A locked section refuses to open rather than opening onto
            // nothing.
            onTap: shelf.isLocked
                ? null
                : () => setState(() => _isOpen = !_isOpen),
          ),
          if (isOpen) _Guides(shelf: shelf),
        ],
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading({
    required this.isLocked,
    required this.isOpen,
    required this.onTap,
  });

  final bool isLocked;
  final bool isOpen;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final ink = isLocked ? mood.inkMute : mood.ink;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.menu_book_outlined, size: AppSpacing.lg, color: ink),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    _title,
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: ink),
                  ),
                ),
                if (isLocked)
                  Icon(Icons.lock_outline, size: AppSpacing.md, color: ink)
                else
                  Icon(
                    isOpen ? Icons.expand_less : Icons.expand_more,
                    color: mood.inkMute,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxs),
            Padding(
              padding: const EdgeInsets.only(left: AppSpacing.xl),
              child: SmallcapsLabel(
                isLocked ? _lockedSubtitle : _openSubtitle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Guides extends StatelessWidget {
  const _Guides({required this.shelf});

  final VisualGuideShelf shelf;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final guide in shelf.earned) _GuideRow(guide: guide),
        if (shelf.remaining > 0)
          Padding(
            padding: const EdgeInsets.only(
              top: AppSpacing.xs,
              left: AppSpacing.xl,
            ),
            child: SmallcapsLabel(_remainingLine(shelf.remaining)),
          ),
      ],
    );
  }
}

class _GuideRow extends StatelessWidget {
  const _GuideRow({required this.guide});

  final VisualGuide guide;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return InkWell(
      onTap: () => showVisualGuideSheet(context, guide),
      child: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: mood.rule)),
        ),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            VisualGuideArt(
              subject: guide.subject,
              size: VisualGuideArtSize.row,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                guide.title,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: mood.ink),
              ),
            ),
            Icon(Icons.chevron_right, color: mood.inkMute),
          ],
        ),
      ),
    );
  }
}
