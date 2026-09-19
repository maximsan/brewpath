import 'package:brew_path/shared/theme/overlay_colors.dart';
import 'package:flutter/material.dart';

/// The control's tap target — the design's 44px, which is also the platform
/// minimum, so it needs no rounding up.
const double _targetSize = 44;

/// The speaker glyph inside it.
const double _glyphSize = 19;

/// Mute and unmute for the Welcome film.
///
/// A circle on the scrim, labelled by what a press does rather than what is
/// true now. It takes the scrim whole, tint and blur — the one overlay
/// `OverlayBarrier` cannot render, since it is not full-screen and its blur
/// must be clipped to the control's shape (#379), blurring the film at 8px.
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
      onTap: onPressed,
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
