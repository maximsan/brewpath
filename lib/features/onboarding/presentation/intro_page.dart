import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The design's page inset for the intro screens — 64 above, 40 below.
const double _topInset = 64;
const double _bottomInset = 40;

/// One intro beat: a full-height column, inset the way the design insets it.
///
/// Deliberately **not** scrollable. These screens are single, fixed beats — a
/// picture, three lines, one way forward — and the design pins their last
/// element to the foot of the screen (`marginTop: 'auto'`). A scroll view
/// gives its child unbounded height, which is precisely what a [Spacer] cannot
/// work in, so making these scroll would cost the pinned foot on every screen
/// to buy nothing on almost all of them.
///
/// What flexes instead is whatever the screen marks [Flexible] — the hero
/// film. On a short viewport it gives up height and the copy stays put, which
/// is the right trade for a screen whose text is three lines long.
class IntroPage extends StatelessWidget {
  /// Creates an [IntroPage].
  const IntroPage({required this.children, super.key});

  /// The page's content, laid out from the top and reaching the foot.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.mood.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            _topInset,
            AppSpacing.lg,
            _bottomInset,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ),
    );
  }
}
