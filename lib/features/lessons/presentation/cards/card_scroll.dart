import 'package:flutter/widgets.dart';

/// The scroll a card lives in: the card fills the viewport and its way on
/// sits at the foot, and a taller card scrolls with the button after it.
///
/// The design lays every card out as `flex: '1 0 auto'` in a `.scroll`
/// column with a `flex: 1` spacer before the button; the minimum height here
/// is that stretch, and `CardShell` spreads its two halves into it.
class CardScroll extends StatelessWidget {
  /// Creates a [CardScroll].
  const CardScroll({required this.padding, required this.child, super.key});

  /// The room around the card, which the minimum height leaves out.
  final EdgeInsets padding;

  /// The card.
  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final room = constraints.maxHeight - padding.vertical;
      return SingleChildScrollView(
        padding: padding,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: room > 0 ? room : 0),
          child: child,
        ),
      );
    },
  );
}
