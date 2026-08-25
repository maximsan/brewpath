import 'package:brew_path/core/widgets/app_sheet.dart';
import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/core/widgets/visual_guide_art.dart';
import 'package:brew_path/features/saved/domain/saved_key.dart';
import 'package:brew_path/features/saved/presentation/saved_bookmark_button.dart';
import 'package:brew_path/shared/models/content/visual_guide.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// Opens [guide] over whatever the learner is looking at.
///
/// Through the app's one sheet primitive, which takes the title as both the
/// heading and the sheet's accessible name — so a reference cannot end up
/// announced as something other than what it says.
Future<void> showVisualGuideSheet(BuildContext context, VisualGuide guide) =>
    showAppSheet<void>(
      context: context,
      title: guide.title,
      builder: (_) => VisualGuideSheetBody(guide: guide),
    );

/// A guide's whole entry: what it is, the drawing, the idea, the table, and
/// the one thing worth repeating.
class VisualGuideSheetBody extends StatelessWidget {
  /// Creates a [VisualGuideSheetBody].
  const VisualGuideSheetBody({required this.guide, super.key});

  /// The guide being read.
  final VisualGuide guide;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Names the kind, because a guide and a collectible look alike and
        // mean different things. The bookmark sits beside it: a reference is
        // kept from where it is read, like a lesson and a term.
        Row(
          children: [
            Expanded(child: SmallcapsLabel(guide.label)),
            SavedBookmarkButton(
              // The guide's **subject**, not its id — `g:roast`, never
              // `g:g-roast`. Both fields exist, so the wrong one would
              // resolve to nothing without ever failing loudly.
              savedKey: formatSavedKey(SavedKind.guide, guide.subject),
              label: guide.title,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        VisualGuideArt(subject: guide.subject, size: VisualGuideArtSize.full),
        const SizedBox(height: AppSpacing.md),
        Text(
          guide.summary,
          style: text.bodyLarge?.copyWith(color: mood.ink),
        ),
        if (guide.metaRows.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          _MetaTable(rows: guide.metaRows),
        ],
        if (guide.note case final note?) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(note, style: text.bodyMedium?.copyWith(color: mood.ink)),
        ],
        const SizedBox(height: AppSpacing.lg),
        _Fact(fact: guide.fact),
      ],
    );
  }
}

/// The guide's two or three key rows — the diagram, in words.
class _MetaTable extends StatelessWidget {
  const _MetaTable({required this.rows});

  final List<VisualGuideMetaRow> rows;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final text = Theme.of(context).textTheme;

    return Column(
      children: [
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: _metaLabelWidth,
                  child: SmallcapsLabel(row.label),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        row.value,
                        style: text.bodyMedium?.copyWith(color: mood.ink),
                      ),
                      // The value names the term; this says what living with
                      // it is like. Only the guides that gloss have it.
                      if (row.detail case final detail?) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          detail,
                          style: text.bodySmall?.copyWith(color: mood.inkMute),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// How much of the row the label column takes, so values line up.
const double _metaLabelWidth = 108;

class _Fact extends StatelessWidget {
  const _Fact({required this.fact});

  final String fact;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: mood.surface,
        borderRadius: BorderRadius.circular(AppRadii.chrome),
      ),
      child: Text(
        fact,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: mood.inkMute),
      ),
    );
  }
}
