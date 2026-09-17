import 'dart:math' as math;

import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/widgets/disclosure.dart';
import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/services/links/link_provider.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The works a term's explanation draws on, behind the standard disclosure.
///
/// **Shut by default.** Provenance is what makes the entry quotable, and it is
/// also the block nobody reads on the way through; it costs one line until
/// asked for. A source with an address opens it in the browser.
class TermSourcesSection extends ConsumerStatefulWidget {
  /// Creates a [TermSourcesSection] over [sources].
  const TermSourcesSection({required this.sources, super.key});

  /// The works to list, each with its address when it has one.
  final List<DictionarySource> sources;

  @override
  ConsumerState<TermSourcesSection> createState() => _TermSourcesSectionState();
}

class _TermSourcesSectionState extends ConsumerState<TermSourcesSection> {
  bool _open = false;

  void _toggle() => setState(() => _open = !_open);

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final count = widget.sources.length;

    return Disclosure(
      isOpen: _open,
      onToggle: _toggle,
      // `SOURCES 2`: the count rides beside the label at the design's mono
      // count weight, as every group header carries its own.
      header: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          const SmallcapsLabel('Sources'),
          const SizedBox(width: AppSpacing.xs),
          Text(
            '$count',
            style: AppText.label(
              mood: mood,
              face: AppFace.mono,
              tracking: AppTracking.count,
            ),
          ),
        ],
      ),
      semanticsLabel: 'Sources, $count',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (index, source) in widget.sources.indexed)
            _SourceRow(
              index: index + 1,
              source: source,
              onOpen: source.url == null
                  ? null
                  : () => ref
                        .read(linkOpenerProvider)
                        .open(
                          Uri.parse(source.url!),
                        ),
            ),
        ],
      ),
    );
  }
}

/// One source: a two-digit index, its name in mono, and — where it has an
/// address — the outward arrow that opens it.
class _SourceRow extends StatelessWidget {
  const _SourceRow({
    required this.index,
    required this.source,
    required this.onOpen,
  });

  /// The design's index column, wide enough for `01`.
  static const double _indexColumn = 28;

  /// The design's outward arrow is the app's arrow turned a quarter up.
  static const double _outwardTurn = -math.pi / 4;

  final int index;
  final DictionarySource source;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final opens = onOpen != null;
    final mono = AppText.label(
      mood: mood,
      face: AppFace.mono,
      tracking: AppTracking.reading,
    );

    return Semantics(
      link: opens,
      label: opens ? '${source.label}, opens in the browser' : source.label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: _indexColumn,
                child: Text(index.toString().padLeft(2, '0'), style: mono),
              ),
              Expanded(child: Text(source.label, style: mono)),
              if (opens) ...[
                const SizedBox(width: AppSpacing.sm),
                Transform.rotate(
                  angle: _outwardTurn,
                  child: IconMark(AppIcon.arrow, color: mood.inkMute),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
