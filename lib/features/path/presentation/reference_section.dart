import 'dart:async';

import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/caret_mark.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/core/widgets/visual_guide_art.dart';
import 'package:brew_path/features/monetization/domain/locked_row_copy.dart';
import 'package:brew_path/features/monetization/domain/plus_gate_trigger.dart';
import 'package:brew_path/features/monetization/presentation/plus_gate_sheet.dart';
import 'package:brew_path/features/path/domain/visual_guide_providers.dart';
import 'package:brew_path/features/path/domain/visual_guide_shelf.dart';
import 'package:brew_path/features/path/presentation/visual_guide_sheet.dart';
import 'package:brew_path/shared/models/content/visual_guide.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Copy, ported as authored.
const _title = 'Reference';
const _openSubtitle = 'Visual guides from your lessons';
String _remainingLine(int remaining) => '$remaining more unlock as you learn';

/// The locked shelf's line, which depends on who is reading it.
///
/// #260 shipped the prototype's one string — *"Visual guides unlock as lessons
/// teach them"* — for both tiers, and recorded that it was honest to neither.
/// The free tier is the first three lessons (ADR-0007) and the earliest guide
/// is taught by the sixth, so "keep learning" is not an instruction a free
/// learner can follow. The owner ruled the line tier-aware on #91; ADR-0015
/// carries it.
String _lockedSubtitle({required bool byPurchase, required String? nextTitle}) {
  if (byPurchase) return LockedRowCopy.referenceLockedFree;
  return nextTitle == null
      ? _openSubtitle
      : LockedRowCopy.referenceUnlocksWith(nextTitle);
}

/// The section's own glyph and its lock mark. Sized here rather than borrowed
/// from `AppSpacing`, whose stops are for spacing — an icon that resizes when
/// a spacing stop is retuned is a coupling nobody asked for.
const double _glyphSize = 24;
const double _lockSize = 16;

/// How long the section takes to open when motion is allowed. The design
/// animates the expansion; this is that, in Flutter's terms.
const _expandDuration = Duration(milliseconds: 320);

/// The last thing on Path: the illustrated references a learner has earned.
///
/// Styled as a section rather than a boxed card, because Path is editorial and
/// a boxed shelf reads as another screen's component.
///
/// **Locked guides are not drawn** — they never leave
/// [deriveVisualGuideShelf], so this cannot render one by mistake. What it
/// shows instead is how many are still to come, which turns the absence into a
/// promise rather than a wall of grey tiles at the moment a learner owns one
/// of eight.
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

    // Unresolved reads as locked-by-purchase, which is what every other
    // entitlement caller does: the free line is the one that is true for
    // someone who has bought nothing, and that is the safe way to be wrong.
    final byPurchase =
        ref.watch(referenceLockedByPurchaseProvider).asData?.value ?? true;
    final subtitle = _lockedSubtitle(
      byPurchase: byPurchase,
      // Only asked for while the shelf is locked, and only true when the
      // learner owns the course — a free reader never sees a lesson name.
      nextTitle: ref.watch(nextGuideUnlockProvider).asData?.value,
    );
    final isOpen = _isOpen && !shelf.isLocked;

    return Semantics(
      container: true,
      label: shelf.isLocked
          ? '$_title, locked. $subtitle'
          : '$_title, ${shelf.earned.length} guides',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Heading(
            isLocked: shelf.isLocked,
            isOpen: isOpen,
            subtitle: shelf.isLocked ? subtitle : _openSubtitle,
            // A locked section refuses to open rather than opening onto
            // nothing — unless the lock is the purchase, which is a thing the
            // learner can act on, so that one raises the offer instead.
            onTap: !shelf.isLocked
                ? () => setState(() => _isOpen = !_isOpen)
                : byPurchase
                ? () => unawaited(
                    showPlusGate(context, const LockedGuides()),
                  )
                : null,
          ),
          _Expansion(
            isOpen: isOpen,
            child: _Guides(shelf: shelf),
          ),
        ],
      ),
    );
  }
}

/// The opening and closing itself.
///
/// ⚠️ **Reduced motion drops the animator rather than zeroing it.**
/// `AnimatedSize` re-dirties itself inside its own `performLayout` when handed
/// `Duration.zero`, which the framework asserts on — the defect that shipped
/// once already in the dictionary's self-check, and which a sweep test now
/// forbids. So "no animation" means no animator.
class _Expansion extends StatelessWidget {
  const _Expansion({required this.isOpen, required this.child});

  final bool isOpen;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final shown = isOpen ? child : const SizedBox(width: double.infinity);
    if (MediaQuery.disableAnimationsOf(context)) return shown;

    return AnimatedSize(
      duration: _expandDuration,
      curve: Curves.easeOut,
      alignment: Alignment.topCenter,
      child: shown,
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading({
    required this.isLocked,
    required this.isOpen,
    required this.subtitle,
    required this.onTap,
  });

  final bool isLocked;
  final bool isOpen;

  /// The line under the title, already chosen for this learner.
  final String subtitle;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final ink = isLocked ? mood.inkMute : mood.ink;

    return Semantics(
      button: onTap != null,
      // Null while there is no expanded state to be in — locked, or locked
      // behind a purchase, where the tap opens an offer rather than the shelf.
      expanded: onTap == null || isLocked ? null : isOpen,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconMark(AppIcon.module, size: _glyphSize, color: ink),
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
                    IconMark(AppIcon.lock, size: _lockSize, color: ink)
                  else
                    CaretMark(open: isOpen, color: mood.inkMute),
                ],
              ),
              const SizedBox(height: AppSpacing.xxs),
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.xl),
                child: SmallcapsLabel(subtitle),
              ),
            ],
          ),
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
        for (var index = 0; index < shelf.earned.length; index++)
          _GuideRow(guide: shelf.earned[index], isFirst: index == 0),
        if (shelf.remaining > 0)
          Padding(
            padding: const EdgeInsets.only(
              top: AppSpacing.xs,
              left: AppSpacing.xl,
            ),
            // Mono, and not uppercased: this is a figure, which is what mono
            // is for here — and a screen reader should read the promise as a
            // sentence rather than shout it.
            child: Text(
              _remainingLine(shelf.remaining),
              style: AppText.label(
                mood: context.mood,
                face: AppFace.mono,
              ),
            ),
          ),
      ],
    );
  }
}

class _GuideRow extends StatelessWidget {
  const _GuideRow({required this.guide, required this.isFirst});

  final VisualGuide guide;

  /// The rule separates rows; it does not sit under the subtitle.
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return InkWell(
      onTap: () => showVisualGuideSheet(context, guide),
      child: Container(
        decoration: BoxDecoration(
          border: isFirst ? null : Border(top: BorderSide(color: mood.rule)),
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
            IconMark(AppIcon.chevron, color: mood.inkMute),
          ],
        ),
      ),
    );
  }
}
