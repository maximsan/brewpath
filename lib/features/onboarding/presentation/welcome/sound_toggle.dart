import 'package:brew_path/shared/theme/overlay_colors.dart';
import 'package:flutter/material.dart';

/// The control's tap target — the design's 44px, which is also the platform
/// minimum, so it needs no rounding up (`screens.jsx:58`).
const double _targetSize = 44;

/// The speaker glyph inside it (`screens.jsx:70`).
const double _glyphSize = 19;

/// Mute and unmute for the Welcome film.
///
/// A circle on the scrim rather than a chrome button: it floats over artwork,
/// so it takes the overlay palette both moods share and never the surface
/// tokens of the page beneath.
///
/// Labelled by what a press *does*, not by what is true now — a reader hearing
/// "turn sound on" knows the outcome, where "muted" leaves them to work it out.
class SoundToggle extends StatelessWidget {
  /// Creates a [SoundToggle].
  const SoundToggle({required this.muted, required this.onPressed, super.key});

  /// Whether the film is currently silent.
  final bool muted;

  /// Fired when the learner flips it.
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: muted ? 'Turn sound on' : 'Turn sound off',
      excludeSemantics: true,
      child: SizedBox(
        width: _targetSize,
        height: _targetSize,
        child: Material(
          color: OverlayColors.scrim,
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
    );
  }
}
