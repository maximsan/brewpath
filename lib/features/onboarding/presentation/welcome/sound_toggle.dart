import 'package:brew_path/shared/theme/overlay_colors.dart';
import 'package:flutter/material.dart';

/// The control's tap target — the design's 44px, which is also the platform
/// minimum, so it needs no rounding up.
const double _targetSize = 44;

/// The speaker glyph inside it.
const double _glyphSize = 19;

/// Mute and unmute for the Welcome film.
///
/// A circle on the scrim rather than a chrome button: it floats over artwork,
/// so it takes the overlay palette both moods share and never the surface
/// tokens of the page beneath.
///
/// Labelled by what a press *does*, not by what is true now — a reader hearing
/// "turn sound on" knows the outcome, where "muted" leaves them to work it out.
///
/// **The scrim is taken whole here**, tint and blur. It is the one overlay
/// `OverlayBarrier` cannot render, because it is the only one of the four that
/// is not full-screen: its blur has to be shaped like the control it sits
/// behind, so the control clips it (#379). The design puts the film behind it
/// at 8px.
class SoundToggle extends StatelessWidget {
  /// Creates a [SoundToggle].
  const SoundToggle({required this.muted, required this.onPressed, super.key});

  /// Whether the film is currently silent.
  final bool muted;

  /// Fired when the learner flips it.
  final VoidCallback onPressed;

  /// The film behind [button], blurred at the scrim's own radius.
  ///
  /// Inside the circle only — the clip is what makes this a control on media
  /// rather than a wash over the screen. Returned unwrapped if the token ever
  /// carries no blur, because a `BackdropFilter` costs a `saveLayer` whatever
  /// its sigma.
  Widget _behindTheGlass(Widget button) {
    final blur = OverlayColors.scrim.backdropFilter;
    if (blur == null) return button;

    return BackdropFilter(filter: blur, child: button);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: muted ? 'Turn sound on' : 'Turn sound off',
      excludeSemantics: true,
      child: SizedBox(
        width: _targetSize,
        height: _targetSize,
        child: ClipOval(
          child: _behindTheGlass(
            Material(
              color: OverlayColors.scrim.color,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onPressed,
                child: Icon(
                  muted ? Icons.volume_off : Icons.volume_up,
                  size: _glyphSize,
                  color: OverlayColors.scrimInk,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
