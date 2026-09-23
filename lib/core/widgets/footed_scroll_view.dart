import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// A page's scroll with one block held at its foot.
///
/// The footer sits at the bottom of the screen while the content above is
/// shorter than the page, and is pushed below the content once it is not —
/// so a signature line never floats halfway down a short page, and never
/// overlaps a long one.
class FootedScrollView extends StatelessWidget {
  /// Creates a scroll of [children] closing on [footer].
  const FootedScrollView({
    required this.scrollPadding,
    required this.children,
    required this.footer,
    this.footerGap = AppSpacing.xl,
    super.key,
  });

  /// The room the page's bar leaves above the scroll.
  final EdgeInsets scrollPadding;

  /// The page's content, in order.
  final List<Widget> children;

  /// The block held at the foot.
  final Widget footer;

  /// The least room between the content and the footer.
  final double footerGap;

  @override
  Widget build(BuildContext context) {
    // The home indicator's room is the scroll's to leave: the footer is the
    // one thing on the page that reaches the bottom of the screen.
    final bottomInset = MediaQuery.paddingOf(context).bottom + AppSpacing.xl;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.only(top: scrollPadding.top),
          sliver: SliverList(
            delegate: SliverChildListDelegate(children),
          ),
        ),
        // Takes the room left over, or the footer's own height when there is
        // none left — which is what puts the footer at the bottom of a short
        // page and under the content of a long one.
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomInset),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(height: footerGap),
                footer,
              ],
            ),
          ),
        ),
      ],
    );
  }
}
