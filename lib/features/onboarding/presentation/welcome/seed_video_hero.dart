import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// The seed-to-tree film behind Welcome's frame.
///
/// Looping unless the platform asks for reduced motion, in which case it holds
/// its first frame.
///
/// **Silent, with no way to unmute — a known divergence, not a decision made
/// here.** The design gives the frame a 44px scrim-backed mute/unmute button
/// (`screens.jsx:46-68`) and the app has never carried it, which is Audit E
/// item 6. #383 rebuilt this screen without ruling on the control either way,
/// so it stays as it was and the finding stays open. Whoever picks item 6 up
/// adds the button here.
///
/// **No mascot.** The design's own comment on Welcome reads *"No Roasty
/// here."* — his first appearance is the whole point of the screen after. So
/// the fallback, when the platform channel is unavailable (every `flutter
/// test` run, and any device that cannot decode the asset), is the bare frame
/// rather than a stand-in drawing.
class SeedVideoHero extends StatefulWidget {
  /// Creates a [SeedVideoHero].
  const SeedVideoHero({super.key});

  @override
  State<SeedVideoHero> createState() => _SeedVideoHeroState();
}

class _SeedVideoHeroState extends State<SeedVideoHero> {
  late final VideoPlayerController _controller;
  bool _initFailed = false;
  bool _started = false;
  bool _reduceMotion = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    _controller = VideoPlayerController.asset(
      'assets/video/Flowerpot_seed_to.mp4',
    );
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
        onError: (_) {
          if (mounted) setState(() => _initFailed = true);
        },
      ),
    );
  }

  @override
  void dispose() {
    unawaited(_controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_initFailed || !_controller.value.isInitialized) {
      return const SizedBox.expand();
    }
    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: _controller.value.size.width,
        height: _controller.value.size.height,
        child: VideoPlayer(_controller),
      ),
    );
  }
}
