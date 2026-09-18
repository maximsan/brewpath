import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/swipe/swipe_geometry.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The first-run hint's words, with an arrow pointing the way.
///
/// Transient: it rides in with the nudge and leaves with it, so what remains is
/// the standing affordance. Decorative, like the nudge — assistive technology
/// is given the surface's own controls, not a gesture it cannot make.
class SwipeHintCaption extends StatelessWidget {
  /// Creates a [SwipeHintCaption]. The design writes [label] upper-case; the
  /// case is the type rule, so it is applied here.
  const SwipeHintCaption({
    required this.show,
    required this.label,
    this.aim = SwipeAim.advance,
    super.key,
  });

  static const Duration _fade = Duration(milliseconds: 280);
  static const double _height = 40;
  static const double _gap = 7;
  static const double _arrow = 22;

  /// Whether the caption is up.
  final bool show;

  /// What the gesture does, in the surface's own words.
  final String label;

  /// Which way the arrow points.
  final SwipeAim aim;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : _fade;
    return ExcludeSemantics(
      child: ClipRect(
        child: AnimatedOpacity(
          opacity: show ? 1 : 0,
          duration: duration,
          child: AnimatedContainer(
            duration: duration,
            height: show ? _height : 0,
            child: OverflowBox(
              minHeight: _height,
              maxHeight: _height,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.flip(
                    flipX: aim == SwipeAim.advance,
                    child: IconMark(
                      AppIcon.arrow,
                      size: _arrow,
                      color: mood.accentText,
                    ),
                  ),
                  const SizedBox(width: _gap),
                  Text(
                    label.toUpperCase(),
                    style: AppText.micro(mood: mood),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
