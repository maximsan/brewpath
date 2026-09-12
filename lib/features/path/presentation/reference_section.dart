import 'dart:async';

import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/disclosure_mark.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/widgets/disclosure.dart';
import 'package:brew_path/core/widgets/module_glyph.dart';
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
import 'package:brew_path/shared/theme/off_token.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Copy, ported as authored.
const _title = 'Reference';
const _openSubtitle = 'Visual guides from your lessons';
String _remainingLine(int remaining) => '$remaining more unlock as you learn';

/// The locked shelf's line, which depends on who is reading it. ADR-0016.
///
/// #260 shipped one string for everyone — "Visual guides unlock as lessons
/// teach them" — and recorded that it was not true for either reader.
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

/// The last thing on Path: the illustrated references a learner has earned.
///
/// A section rather than a boxed card, because Path is editorial. **Locked
/// guides are not drawn** — they never leave [deriveVisualGuideShelf] — and
/// what shows instead is how many are still to come, which turns the absence
/// into a promise rather than a wall of grey tiles.
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

    // Unresolved reads as locked by purchase, like every other entitlement
    // caller. It is the safer of the two ways to be wrong for a moment.
    final byPurchase =
        ref.watch(referenceLockedByPurchaseProvider).asData?.value ?? true;
    final subtitle = _lockedSubtitle(
      byPurchase: byPurchase,
      nextTitle: ref.watch(nextGuideUnlockProvider).asData?.value,
    );
    final isOpen = _isOpen && !shelf.isLocked;
    final mood = context.mood;
    final ink = shelf.isLocked ? mood.inkMute : mood.ink;

    return Semantics(
      container: true,
      label: shelf.isLocked
          ? '$_title, locked. $subtitle'
          : '$_title, ${shelf.earned.length} guides',
      child: Disclosure(
        isOpen: isOpen,
        collapsible: !shelf.isLocked,
        // A locked section will not open onto nothing. If the lock is the
        // purchase, it offers the way past instead.
        onToggle: _headerTap(locked: shelf.isLocked, byPurchase: byPurchase),
        glyphSize: DisclosureMark.sectionCaretSize,
        headerPadding: EdgeInsets.zero,
        panelPadding: EdgeInsets.only(top: OffTokens.referenceShelfHead.value),
        header: Row(
          children: [
            // The same 32-px column a module glyph sits in, so Reference's
            // title and caption line up with every module above it.
            SizedBox(
              width: ModuleGlyph.columnWidth,
              child: Center(
                child: IconMark(AppIcon.module, size: _glyphSize, color: ink),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                _title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: ink),
              ),
            ),
          ],
        ),
        trailing: shelf.isLocked
            ? IconMark(AppIcon.lock, size: _lockSize, color: ink)
            : null,
        below: Padding(
          padding: const EdgeInsets.only(
            top: AppSpacing.xs,
            left: ModuleGlyph.titleInset,
          ),
          child: SmallcapsLabel(shelf.isLocked ? subtitle : _openSubtitle),
        ),
        child: _Guides(shelf: shelf),
      ),
    );
  }

  VoidCallback? _headerTap({required bool locked, required bool byPurchase}) {
    if (!locked) return () => setState(() => _isOpen = !_isOpen);
    if (!byPurchase) return null;
    return () => unawaited(showPlusGate(context, const LockedGuides()));
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
