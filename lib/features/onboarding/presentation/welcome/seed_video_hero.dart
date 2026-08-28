import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// The seed-to-tree film behind Welcome's frame.
///
/// Silent and looping: it is scenery, not content, and the design gives the
/// v1 screen no sound control (`screens.jsx:46-68` is the prototype's, and it
/// belongs to a screen state this cut does not ship).
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

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(
      'assets/video/Flowerpot_seed_to.mp4',
    );
    unawaited(_controller.setLooping(true));
    unawaited(_controller.setVolume(0));
    unawaited(
      _controller.initialize().then(
        (_) {
          if (mounted) {
            setState(() {});
            unawaited(_controller.play());
          }
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
