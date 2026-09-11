import 'dart:async';

import 'package:brew_path/shared/theme/app_motion.dart';
import 'package:flutter/material.dart';

/// The panel under a disclosure header, growing and shrinking as it is asked.
///
/// Its padding sits inside the clipped box, so a shut panel adds no height,
/// and its contents are dropped once shut — nothing to read out, nothing to
/// tab into.
class DisclosurePanel extends StatefulWidget {
  /// Creates a panel holding [child], shown while [isOpen].
  const DisclosurePanel({
    required this.isOpen,
    required this.child,
    this.padding = EdgeInsets.zero,
    super.key,
  });

  /// Whether the panel is open.
  final bool isOpen;

  /// The room inside the panel.
  final EdgeInsets padding;

  /// What the panel holds.
  final Widget child;

  @override
  State<DisclosurePanel> createState() => _DisclosurePanelState();
}

class _DisclosurePanelState extends State<DisclosurePanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.disclosure,
    value: widget.isOpen ? 1 : 0,
  );

  late final CurvedAnimation _heightFactor = CurvedAnimation(
    parent: _controller,
    curve: AppMotion.disclosurePanel,
  );

  @override
  void didUpdateWidget(DisclosurePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOpen == oldWidget.isOpen) return;
    unawaited(widget.isOpen ? _controller.forward() : _controller.reverse());
  }

  @override
  void dispose() {
    _heightFactor.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Reduced motion cuts the move rather than dropping the animator, the way
    // the Tour's frame does: the panel still has to arrive.
    _controller.duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : AppMotion.disclosure;

    return AnimatedBuilder(
      animation: _heightFactor,
      // Full width by hand: the clip aligns its child, and an aligned child is
      // laid out loose — rows that fit their content would centre themselves.
      child: SizedBox(
        width: double.infinity,
        child: Padding(padding: widget.padding, child: widget.child),
      ),
      builder: (context, panel) {
        if (!widget.isOpen && _controller.isDismissed) {
          return const SizedBox.shrink();
        }
        return ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: _heightFactor.value,
            child: panel,
          ),
        );
      },
    );
  }
}
