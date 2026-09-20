import 'dart:async';

import 'package:brew_path/features/dictionary/domain/dictionary_providers.dart';
import 'package:brew_path/features/dictionary/domain/term_links.dart';
import 'package:brew_path/features/dictionary/presentation/term_peek_sheet.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A run of lesson copy with the glossary terms it says drawn as links.
///
/// Tapping one opens the term peek sheet, so checking a word never costs the
/// card the learner is on. Copy the index does not recognise draws exactly as
/// a plain [Text] would.
class TermLinkedText extends ConsumerStatefulWidget {
  /// Creates a [TermLinkedText].
  const TermLinkedText({required this.text, this.style, super.key});

  /// The copy to draw.
  final String text;

  /// How the run is set. The links inherit it and override only the colour,
  /// the weight and the rule under them.
  final TextStyle? style;

  @override
  ConsumerState<TermLinkedText> createState() => _TermLinkedTextState();
}

class _TermLinkedTextState extends ConsumerState<TermLinkedText> {
  /// The design's `color-mix(in oklab, accent 60%, transparent)` on the rule.
  static const double _underlineOpacity = 0.6;

  /// The design's `1.5px dotted` rule, as the multiple of the font's own
  /// underline stroke that Flutter takes: Plex Sans Medium strokes 0.077em,
  /// which is 1.155px at the body step the concept card's prose is set in.
  static const double _underlineThickness = 1.3;

  List<TermTextSegment> _segments = const [];

  /// One tap per linked term, built with the segments and disposed with them —
  /// a recognizer made in `build` would leak a new one every frame.
  final Map<String, TapGestureRecognizer> _taps = {};

  TermLinkIndex? _indexed;
  String? _segmented;

  @override
  void dispose() {
    _releaseTaps();
    super.dispose();
  }

  void _releaseTaps() {
    for (final tap in _taps.values) {
      tap.dispose();
    }
    _taps.clear();
  }

  /// Splits the copy once per card rather than once per frame: card copy is
  /// static, and the index only changes when the learner's dictionary does.
  void _resegment(TermLinkIndex index) {
    if (identical(_indexed, index) && _segmented == widget.text) return;
    _indexed = index;
    _segmented = widget.text;
    _segments = index.segmentsIn(widget.text);
    _releaseTaps();
    for (final segment in _segments) {
      if (segment.termId case final termId?) {
        _taps[termId] = TapGestureRecognizer()
          ..onTap = () => unawaited(showTermPeekSheet(context, termId));
      }
    }
  }

  /// The design's `fontWeight: 500` is the control face: the same Plex Sans
  /// the copy around it is set in, at the one cut the bundle carries for it.
  TextStyle _linkStyle(MoodColors mood) => TextStyle(
    color: mood.accent,
    fontFamily: AppFace.control.family,
    fontWeight: AppFace.control.weight,
    decoration: TextDecoration.underline,
    decorationStyle: TextDecorationStyle.dotted,
    decorationColor: mood.accent.withValues(alpha: _underlineOpacity),
    decorationThickness: _underlineThickness,
  );

  @override
  Widget build(BuildContext context) {
    final index =
        ref.watch(termLinkIndexProvider).asData?.value ?? TermLinkIndex.empty;
    _resegment(index);

    final linkStyle = _linkStyle(context.mood);
    return Text.rich(
      TextSpan(
        children: [
          for (final segment in _segments)
            if (segment.termId case final termId?)
              // A span carrying a tap is announced on its own, as a link named
              // by the words on the page. Naming it by the bank's spelling
              // instead would rewrite the sentence a reader hears.
              TextSpan(
                text: segment.text,
                style: linkStyle,
                recognizer: _taps[termId],
              )
            else
              TextSpan(text: segment.text),
        ],
      ),
      style: widget.style,
    );
  }
}
