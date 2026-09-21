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

  /// The style, merged onto the ambient one exactly as [Text] merges it, so
  /// the measurement and the paint cannot come to disagree.
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final ambient = DefaultTextStyle.of(context).style;
    final resolved = switch (style) {
      null => ambient,
      final own when !own.inherit => own,
      final own => ambient.merge(own),
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        final room = constraints.maxWidth;
        final text = Text(data, style: resolved);
        if (!room.isFinite) return text;

        // Padded rather than sized: a list lays its children out at a tight
        // width, which a narrower box would simply be stretched back out of.
        return Padding(
          padding: EdgeInsetsDirectional.only(
            end:
                room -
                balancedWrapWidth(
                  text: data,
                  style: resolved,
                  maxWidth: room,
                  textDirection: Directionality.of(context),
                  textScaler: MediaQuery.textScalerOf(context),
                ),
          ),
          child: text,
        );
      },
    );
  }
}
