import 'package:brew_path/core/widgets/disclosure.dart';
import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The works a term's explanation draws on, behind the standard disclosure.
///
/// **Shut by default.** Provenance is what makes the entry quotable, and it is
/// also the block nobody reads on the way through; it costs one line until
/// asked for.
class TermSourcesSection extends StatefulWidget {
  /// Creates a [TermSourcesSection] over [sources].
  const TermSourcesSection({required this.sources, super.key});

  /// The works to list, each with its address when it has one.
  final List<DictionarySource> sources;

  @override
  State<TermSourcesSection> createState() => _TermSourcesSectionState();
}

class _TermSourcesSectionState extends State<TermSourcesSection> {
  bool _open = false;

  void _toggle() => setState(() => _open = !_open);

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final text = Theme.of(context).textTheme;

    return Disclosure(
      isOpen: _open,
      onToggle: _toggle,
      header: const SmallcapsLabel('Sources'),
      semanticsLabel: 'Sources, ${widget.sources.length}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final source in widget.sources)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    source.label,
                    style: text.bodySmall?.copyWith(color: mood.inkMute),
                  ),
                  // Shown as text, not a link: opening one needs a
                  // URL-launching dependency, which is a platform decision
                  // this work did not take on.
                  if (source.url != null)
                    SelectableText(
                      source.url!,
                      style: text.bodySmall?.copyWith(color: mood.water),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
