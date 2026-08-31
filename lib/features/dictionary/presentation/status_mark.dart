import 'package:brew_path/features/dictionary/domain/dictionary_derivations.dart';
import 'package:brew_path/features/dictionary/presentation/dictionary_status_style.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The mark's diameter.
const double _markSize = 10;

/// The ring's weight when the mark is not filled — the icon family's stroke,
/// so the dot sits at the same weight as every glyph beside it.
const double _markStroke = 1.6;

/// Reference is a **dash**, not a ring: it is not a lesser "not yet", it is
/// off the path entirely, and a ring would say the course is coming to it
/// (`dictionary.jsx:126`).
const double _dashWidth = 7;
const double _dashHeight = 1.5;
const double _dashAlpha = 0.55;

/// Where a term sits on the path, as one dot.
///
/// Filled when learned, an outline for *not yet*, and a dash for a term the
/// course never teaches. Colour carries which of the three it is.
///
/// **Never drawn alone.** Hue is the one thing a screen reader cannot report,
/// so every surface pairs this with the status word — the row puts it beside
/// the term's name, `StatusChip` wraps it in one. It carries no semantics of
/// its own for that reason: the word next to it is the label.
class StatusMark extends StatelessWidget {
  /// Creates a [StatusMark].
  const StatusMark({required this.status, super.key});

  /// The state being drawn.
  final DictionaryStatus status;

  @override
  Widget build(BuildContext context) {
    final colour = status.colorFrom(context.mood);

    if (status == DictionaryStatus.reference) {
      return Container(
        width: _dashWidth,
        height: _dashHeight,
        decoration: BoxDecoration(
          color: colour.withValues(alpha: _dashAlpha),
          borderRadius: BorderRadius.circular(_dashHeight),
        ),
      );
    }

    return Container(
      width: _markSize,
      height: _markSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: status.isFilled ? colour : null,
        border: status.isFilled
            ? null
            : Border.all(color: colour, width: _markStroke),
      ),
    );
  }
}
