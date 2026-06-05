import 'package:coffee_quest/features/onboarding/presentation/widgets/roasty_state.dart';

/// The six ordered steps of Roasty's wake-up sequence.
/// Each phase owns its own on-screen [duration] and
/// derives every piece of UI state (caption, drop
/// overlay, mascot pose) so adding or reordering a step can't desync them.
enum WakePhase {
  sleeping(Duration(milliseconds: 1200)),
  dropFalling(Duration(milliseconds: 800)),
  awake(Duration(milliseconds: 600)),
  sproutGrows(Duration(milliseconds: 700)),
  idleBob(Duration(milliseconds: 1800)),
  hold(Duration(milliseconds: 1400));

  const WakePhase(this.duration);

  final Duration duration;

  /// The next phase, looping back to [sleeping] after [hold].
  WakePhase get next => this == values.last ? values.first : values[index + 1];

  /// Whether the "Brewing your lesson" caption is visible in this phase.
  bool get showsCaption => index >= idleBob.index;

  /// Whether the falling water-drop overlay plays in this phase.
  bool get showsDrop => this == dropFalling;

  /// The mascot pose for this phase.
  RoastyState get roastyState => switch (this) {
    sleeping || dropFalling => RoastyState.sleep,
    awake || sproutGrows => RoastyState.awake,
    idleBob || hold => RoastyState.idle,
  };
}

/// One frame of the falling-drop animation, expressed in normalized units:
/// [top] is a 0–1 fraction of the stage height; [opacity] is 0–1; [scaleX]/
/// [scaleY] apply the impact squash.
typedef DropFrame = ({
  double top,
  double opacity,
  double scaleX,
  double scaleY,
});

// Keyframe constants for the falling drop, in 0–1 controller-progress units,
// mirroring the `loading-drop-fall` CSS keyframes. The span values are stored
// as literals (not derived as `1 - start`) to preserve exact float behavior.
const _dropStartTop = 0.14; // stage-height fraction at t=0
const _dropImpactTop = 0.41; // stage-height fraction at impact
const _dropImpactStart = 0.75; // travel completes / squash begins here
const _dropFadeInEnd = 0.3; // opacity ramps 0→1 over 0..this
const _dropFadeOutStart = 0.85; // opacity ramps 1→0 over this..1
const _dropFadeOutSpan = 0.15; // width of the fade-out ramp (1 - 0.85)
const _dropSquashSpan = 0.25; // width of the squash ramp (1 - 0.75)
const _dropSquashAmount = 0.6; // peak squash/stretch on impact

/// Pure keyframe evaluation for the falling drop, mirroring the
/// `loading-drop-fall` CSS keyframes (top 14% → 41%, fade in over 0–30%,
/// squash from 75% on impact). [progress] is the controller value in 0–1.
DropFrame wakeDropFrame(double progress) {
  final top = _dropStartTop +
      (_dropImpactTop - _dropStartTop) *
          progress.clamp(0.0, _dropImpactStart) /
          _dropImpactStart;
  final rawOpacity = progress < _dropFadeInEnd
      ? progress / _dropFadeInEnd
      : (progress > _dropFadeOutStart
            ? (1 - progress) / _dropFadeOutSpan
            : 1.0);
  final scaleX = progress > _dropImpactStart
      ? 1.0 + (progress - _dropImpactStart) / _dropSquashSpan * _dropSquashAmount
      : 1.0;
  final scaleY = progress > _dropImpactStart
      ? 1.0 - (progress - _dropImpactStart) / _dropSquashSpan * _dropSquashAmount
      : 1.0;
  return (
    top: top,
    opacity: rawOpacity.clamp(0.0, 1.0),
    scaleX: scaleX,
    scaleY: scaleY,
  );
}

const _dotRestOpacity = 0.22; // opacity at the trough of the pulse
const _dotPeakPhase = 0.5; // peak occurs at the half-period

/// Pure opacity curve for a single pulsing dot: a 0.22 → 1 → 0.22 triangle
/// wave over one period, offset by [delay] (also in 0–1 period units).
double pulsingDotOpacity(double progress, double delay) {
  final phase = (progress - delay) % 1.0;
  final normalizedPhase = phase < 0 ? phase + 1 : phase;
  final wave = (1 - (normalizedPhase - _dotPeakPhase).abs() * 2).clamp(0.0, 1.0);
  return _dotRestOpacity + (1 - _dotRestOpacity) * wave;
}
