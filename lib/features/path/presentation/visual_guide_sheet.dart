import 'package:brew_path/core/widgets/app_sheet.dart';
import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/features/path/presentation/visual_guide_art.dart';
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
        // mean different things.
        SmallcapsLabel(guide.label),
        const SizedBox(height: AppSpacing.md),
        VisualGuideArt(subject: guide.subject, size: VisualGuideArtSize.sheet),
        const SizedBox(height: AppSpacing.md),
        Text(
          guide.summary,
          style: text.bodyLarge?.copyWith(color: mood.ink),
        ),
        if (guide.metaRows.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          _MetaTable(rows: guide.metaRows),
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
                  child: Text(
                    row.value,
                    style: text.bodyMedium?.copyWith(color: mood.ink),
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
