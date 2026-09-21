import 'package:brew_path/core/widgets/balanced_text_wrap.dart';
import 'package:flutter/widgets.dart';

/// Text laid out in the narrowest box that still holds it in as few lines as
/// the room allows — the design's `textWrap: 'balance'`.
///
/// For a heading that wraps, which is where the design asks for it: the last
/// line is not left holding one word. The width is [balancedWrapWidth]'s, so
/// the rule is testable without pumping a widget.
class BalancedText extends StatelessWidget {
  /// Draws [data] balanced, in [style].
  const BalancedText(this.data, {this.style, super.key});

  /// The line to draw.
  final String data;

  /// The style, resolved against the ambient one exactly as [Text] resolves
  /// it.
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    // Resolved the way `Text` resolves it, so the measurement and the paint
    // cannot come to disagree.
    var resolved = style ?? const TextStyle();
    if (resolved.inherit) {
      resolved = DefaultTextStyle.of(context).style.merge(style);
    }
    // Under Bold Text, `Text` paints a weight this cannot ask for — naming one
    // is the face table's alone — so it hands the line back unbalanced rather
    // than laying out a box measured from the wrong letterforms.
    final measurable = !MediaQuery.boldTextOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final room = constraints.maxWidth;
        final text = Text(data, style: resolved);
        if (!room.isFinite || !measurable) return text;

        final balanced = balancedWrapWidth(
          text: data,
          style: resolved,
          maxWidth: room,
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
        );

        // Padded rather than sized: a list lays its children out at a tight
        // width, which a narrower box would simply be stretched back out of.
        return Padding(
          padding: EdgeInsetsDirectional.only(end: room - balanced),
          child: text,
        );
      },
    );
  }
}
