import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// How far a reward screen scrolls before its topbar takes chrome.
///
/// Far enough that settling the content by a few pixels does not flash a
/// header on and off, near enough that a learner who has begun reading has a
/// bar to close from.
const double floatTopbarThreshold = 40;

/// The design's `transition: … 260ms ease` on the bar's fill, rule and blur.
const Duration floatTopbarFade = Duration(milliseconds: 260);

/// Whether a bar scrolled to [offset] has taken its chrome.
///
/// Pure so the threshold is assertable without a scroll gesture — and named,
/// because a bare `> 40` at a call site is the kind of number that drifts
/// between the two screens that share this bar.
bool floatTopbarIsScrolled(double offset) => offset > floatTopbarThreshold;

/// A floating close or back control over a full-bleed screen: transparent at
/// rest, standard header chrome once the content has moved under it.
///
/// **Chrome, not content.** It sits above the scroll rather than in it, so it
/// stays reachable on a long ending — and takes a fill only when there is
/// something behind it to separate from, which is what stops a control
/// floating over a celebration from looking like a mistake.
class FloatTopbar extends StatelessWidget {
  /// Creates a [FloatTopbar].
  const FloatTopbar({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.isScrolled,
    super.key,
  });

  /// The mark — a close on a screen you leave, a back on one you turn over.
  final AppIcon icon;

  /// What the control is called, for the tooltip and the screen reader.
  final String label;

  /// What pressing it does.
  final VoidCallback onPressed;

  /// Whether the content has scrolled far enough for the bar to take chrome.
  final bool isScrolled;

  /// The design's 44×44 header control.
  static const double hitSize = 44;

  /// The bar's own height, which is the header's.
  static const double height = 56;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return AnimatedContainer(
      duration: floatTopbarFade,
      curve: Curves.ease,
      height: height + MediaQuery.paddingOf(context).top,
      decoration: BoxDecoration(
        color: isScrolled ? mood.bg : mood.bg.withValues(alpha: 0),
        border: Border(
          bottom: BorderSide(
            color: isScrolled ? mood.rule : mood.rule.withValues(alpha: 0),
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: IconButton(
              onPressed: onPressed,
              tooltip: label,
              constraints: const BoxConstraints.tightFor(
                width: hitSize,
                height: hitSize,
              ),
              icon: IconMark(icon, color: mood.ink, semanticLabel: label),
            ),
          ),
        ),
      ),
    );
  }
}

/// Reports whether the scrollable beneath it has passed the bar's threshold.
///
/// A listener rather than a `ScrollController`, because the reward screens do
/// not own their scrollable — `StickyActionBar` does, so there is no
/// controller for a caller to attach. The notification is filtered to depth 0
/// so a nested scroller inside the content cannot flip the page's bar, which
/// is the same rule the design writes as *"currentTarget, not target"*.
class FloatTopbarScrollScope extends StatefulWidget {
  /// Creates a [FloatTopbarScrollScope].
  const FloatTopbarScrollScope({required this.builder, super.key});

  /// Builds the screen, given whether it has scrolled past the threshold.
  final Widget Function(BuildContext context, {required bool isScrolled})
  builder;

  @override
  State<FloatTopbarScrollScope> createState() => _FloatTopbarScrollScopeState();
}

class _FloatTopbarScrollScopeState extends State<FloatTopbarScrollScope> {
  bool _isScrolled = false;

  bool _onScroll(ScrollNotification notification) {
    if (notification.depth != 0) return false;
    final scrolled = floatTopbarIsScrolled(notification.metrics.pixels);
    if (scrolled != _isScrolled) setState(() => _isScrolled = scrolled);
    return false;
  }

  @override
  Widget build(BuildContext context) =>
      NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: widget.builder(context, isScrolled: _isScrolled),
      );
}
