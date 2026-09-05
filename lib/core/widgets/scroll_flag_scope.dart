import 'package:flutter/material.dart';

/// How far a page scrolls before the bar over it takes its chrome.
///
/// Far enough that settling the content by a few pixels does not flash a bar
/// on and off, near enough that a learner who has begun reading has a bar to
/// go back from. The design sets it once, as the default of the one hook every
/// screen-level bar reads, so a page cannot pick its own.
///
/// The tab header is the exception, and it says why: it waits until the tab's
/// large title has gone all the way under it, which is further.
const double scrollFlagThreshold = 40;

/// Whether a page scrolled to [offset] has passed the threshold.
///
/// Pure, so the rule is assertable without a scroll gesture — and named,
/// because a bare `> 40` at a call site is the kind of number that drifts
/// between the screens that share a bar.
bool isScrolledPast(double offset) => offset > scrollFlagThreshold;

/// Reports whether the scrollable beneath it has passed the threshold.
///
/// A listener rather than a `ScrollController`, because a screen does not
/// always own its scrollable — `StickyActionBar` owns one, and a body that
/// swaps between two of them owns neither. The notification is filtered to
/// depth 0 so a nested scroller inside the content cannot flip the page's bar,
/// which is the rule the design writes as *"currentTarget, not target"*.
///
/// **[resetKey] is the failure mode this exists to prevent.** When a screen
/// swaps its content inside the *same* bar — a dictionary category drilled
/// into, a term that links to another term — the content starts at the top
/// again while the flag stays true, leaving a filled bar and a compact title
/// stacked on an un-scrolled large one. Hand it the value that identifies the
/// content and the flag clears with the content.
class ScrollFlagScope extends StatefulWidget {
  /// Creates a [ScrollFlagScope].
  const ScrollFlagScope({
    required this.builder,
    this.resetKey,
    super.key,
  });

  /// Builds the screen, given whether it has scrolled past the threshold.
  final Widget Function(BuildContext context, {required bool isScrolled})
  builder;

  /// What identifies the content under the bar. When it changes, the flag
  /// clears — because the content it described has gone.
  final Object? resetKey;

  @override
  State<ScrollFlagScope> createState() => _ScrollFlagScopeState();
}

class _ScrollFlagScopeState extends State<ScrollFlagScope> {
  bool _isScrolled = false;

  bool _onScroll(ScrollNotification notification) {
    if (notification.depth != 0) return false;
    final scrolled = isScrolledPast(notification.metrics.pixels);
    if (scrolled != _isScrolled) setState(() => _isScrolled = scrolled);
    return false;
  }

  @override
  void didUpdateWidget(ScrollFlagScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Cleared in the same frame the content changes, rather than waiting for a
    // scroll notification that a fresh scroller at offset zero never sends.
    if (widget.resetKey != oldWidget.resetKey && _isScrolled) {
      _isScrolled = false;
    }
  }

  @override
  Widget build(BuildContext context) =>
      NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: widget.builder(context, isScrolled: _isScrolled),
      );
}
