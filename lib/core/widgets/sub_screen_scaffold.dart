import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/widgets/scroll_flag_scope.dart';
import 'package:brew_path/core/widgets/sub_header.dart';
import 'package:flutter/material.dart';

/// Builds a page's body, given the room its scroll must leave at the top.
///
/// The padding is handed over rather than applied here because a page owns the
/// shape of its own scroll — a list, a sliver view, one that swaps for another
/// — and only the thing that builds the scrollable can put padding inside it.
/// Applying it outside would clip the content at the bar instead of letting it
/// pass under.
typedef SubScreenBodyBuilder =
    Widget Function(BuildContext context, EdgeInsets scrollPadding);

/// A page opened from a tab: the design's bar floating over the page's own
/// scroll, with the flag that tells the bar when to appear.
///
/// It exists so no screen has to wire the same four things together — the bar,
/// the scroll flag, the room the scroll leaves for the bar, and the reset that
/// keeps the two honest when the content underneath is swapped. Fifteen
/// screens each answering that separately is how the app ended up with fifteen
/// stock `AppBar`s in the first place.
///
/// **The page still carries its own `PageLargeTitle`.** That is deliberate:
/// the title is inside the scroll, which is the page's, and a scaffold that
/// inserted it would have to own the scroll to do it — which is exactly the
/// freedom the bodies here need.
class SubScreenScaffold extends StatelessWidget {
  /// Creates a [SubScreenScaffold].
  const SubScreenScaffold({
    required this.title,
    required this.body,
    this.eyebrow,
    this.onBack,
    this.mark = AppIcon.back,
    this.backLabel,
    this.trailing,
    this.isRinged = false,
    this.resetKey,
    this.floatingActionButton,
    super.key,
  });

  /// What the page is called — the same words its large title carries.
  final String title;

  /// The page's own scroll, given the room to leave above it.
  final SubScreenBodyBuilder body;

  /// The smallcaps line above the bar's title, where the page has one.
  final String? eyebrow;

  /// What leaving the page does.
  final VoidCallback? onBack;

  /// Back on a page you came into, close on one you dismiss.
  final AppIcon mark;

  /// What the control is called, where the mark's own word is not enough.
  final String? backLabel;

  /// Controls on the right of the bar.
  final Widget? trailing;

  /// Whether the way back is circled, to balance a [trailing] control.
  final bool isRinged;

  /// What identifies the content under the bar, where the page can swap it
  /// without leaving. See [ScrollFlagScope.resetKey].
  final Object? resetKey;

  /// Passed through to the `Scaffold`, for the pages that carry one.
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    // The bar reaches up under the status bar, so the page's own content has
    // to start below both.
    final scrollPadding = EdgeInsets.only(
      top: MediaQuery.paddingOf(context).top + SubHeader.scrollPad,
    );

    return ScrollFlagScope(
      resetKey: resetKey,
      builder: (context, {required isScrolled}) => Scaffold(
        floatingActionButton: floatingActionButton,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Keyed on the same value the flag resets to, so a content swap
            // builds a fresh scrollable at the top *and* clears the bar. The
            // design's hook does both halves together for the same reason:
            // either one alone leaves a compact title stacked on an
            // un-scrolled large one.
            KeyedSubtree(
              key: resetKey == null ? null : ValueKey<Object>(resetKey!),
              child: body(context, scrollPadding),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SubHeader(
                title: title,
                isScrolled: isScrolled,
                eyebrow: eyebrow,
                onBack: onBack,
                mark: mark,
                backLabel: backLabel,
                trailing: trailing,
                isRinged: isRinged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
