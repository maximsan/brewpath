import 'dart:async';

import 'package:brew_path/features/onboarding/presentation/welcome/sound_toggle.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// How far the sound control sits from the frame's corner
/// (`screens.jsx:59`).
const double _controlInset = 12;

/// The seed-to-tree film behind Welcome's frame.
///
/// Looping unless the platform asks for reduced motion, in which case it holds
/// its first frame.
///
/// Muted on arrival, with the design's control to unmute (`screens.jsx:46-68`)
/// — Audit E item 6, which the app had never carried and which no ticket owned.
/// It is fixed here because this is the screen being built; the alternative was
/// reopening a screen the week after writing it.
///
/// The audio never bleeds into the screen after: the track is silenced on the
/// way out, not merely left behind, so unmuting and tapping straight on cannot
/// carry sound into Meet Roasty.
///
/// The design backs the button with a blurred scrim. The **colour** is drawn
/// here; the blur is not — no overlay in the app has its radius yet, which is
/// [#379](https://github.com/maximsan/brewpath/issues/379)'s to port for all
/// of them at once.
///
/// **The film's own first frame stands in for it** while the player is
/// starting, and for good when it cannot start. The frame is the film's, not
/// a stand-in drawing: the design's own comment on Welcome reads *"No Roasty
/// here."* — his first appearance is the whole point of the screen after. The
/// still is `Flowerpot_seed_to_poster.jpg`, frame 0 of the film
/// (`ffmpeg -ss 0 -frames:v 1`), and it is what reduced motion would have
/// held anyway.
///
/// The player *does* fail: a simulator whose CoreAudio cannot open an output
/// device refuses the item (`AVFoundationErrorDomain -11800`, status
/// `-12746`) although the film is plain H.264 with an AAC track, and the frame
/// sat empty with nothing to say why. The reason now goes to the debug console.
class SeedVideoHero extends StatefulWidget {
  /// Creates a [SeedVideoHero].
  const SeedVideoHero({super.key});

  /// The film, as the bundle names it.
  static const String film = 'assets/video/Flowerpot_seed_to.mp4';

  /// Its first frame, for the moments the film itself cannot be shown.
  static const String poster = 'assets/video/Flowerpot_seed_to_poster.jpg';

  @override
  State<SeedVideoHero> createState() => _SeedVideoHeroState();
}

class _SeedVideoHeroState extends State<SeedVideoHero> {
  late final VideoPlayerController _controller;
  bool _initFailed = false;
  bool _started = false;
  bool _reduceMotion = false;
  bool _muted = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    _controller = VideoPlayerController.asset(SeedVideoHero.film);
    unawaited(_controller.setVolume(0));
    // A film that loops forever is exactly what reduced motion switches off.
    // The frame still carries the picture — the controller is initialised and
    // left paused on its first frame — so the screen keeps its subject and
    // loses only the movement.
    unawaited(_controller.setLooping(!_reduceMotion));
    unawaited(
      _controller.initialize().then(
        (_) {
          if (!mounted) return;
          setState(() {});
          if (!_reduceMotion) unawaited(_controller.play());
        },
        onError: (Object error) {
          if (kDebugMode) debugPrint('Welcome film did not start: $error');
          if (mounted) setState(() => _initFailed = true);
        },
      ),
    );
  }

  void _toggleSound() {
    setState(() => _muted = !_muted);
    unawaited(_controller.setVolume(_muted ? 0 : 1));
    // Unmuting a paused film would be sound with no picture, so it plays on —
    // except under reduced motion, where the stillness is the point.
    if (!_muted && !_reduceMotion) unawaited(_controller.play());
  }

  @override
  void dispose() {
    // Silence before release, so nothing survives the frame we leave on.
    unawaited(_controller.setVolume(0));
    unawaited(_controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_initFailed || !_controller.value.isInitialized) {
      return Image.asset(
        SeedVideoHero.poster,
        fit: BoxFit.cover,
        // A bundle without the still leaves the bare frame, as before.
        errorBuilder: (context, error, stackTrace) => const SizedBox.expand(),
      );
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _controller.value.size.width,
            height: _controller.value.size.height,
            child: VideoPlayer(_controller),
          ),
        ),
        Positioned(
          right: _controlInset,
          bottom: _controlInset,
          child: SoundToggle(muted: _muted, onPressed: _toggleSound),
        ),
      ],
    );
  }
}
