import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

/// A [VideoPlayerPlatform] that reports a film without one.
///
/// `video_player` is a federated plugin: the package callers use is a facade
/// over this interface, and the code that decodes anything lives in
/// `video_player_avfoundation` / `video_player_android`, which register
/// themselves through **native** plugin registration. `flutter test` runs in
/// `flutter_tester`, which has no native side, so nothing registers and the
/// interface keeps its placeholder — every call throws
/// `UnimplementedError: init() has not been implemented`.
///
/// The consequence is not a noisy failure but a silent one: the hero catches
/// that error, falls back, and every widget test sees a screen with no film
/// and none of the controls that sit on it. Whole behaviours went untestable
/// by accident of the harness rather than by choice.
///
/// So this stands in. It decodes nothing — it reports one frame of a fixed
/// size and answers the rest — and it records the calls a test needs to assert
/// on, [volumes] above all, because "the sound does not follow you to the next
/// screen" is a claim about a call, not about a pixel.
class FakeVideoPlayerPlatform extends VideoPlayerPlatform
    with MockPlatformInterfaceMixin {
  /// Creates a [FakeVideoPlayerPlatform] without installing it.
  FakeVideoPlayerPlatform();

  /// Creates a [FakeVideoPlayerPlatform] and installs it as the platform for
  /// the current test.
  ///
  /// Nothing is restored afterwards: each test gets a fresh binding, and the
  /// value being replaced is the placeholder that throws on every call.
  factory FakeVideoPlayerPlatform.installed() {
    final fake = FakeVideoPlayerPlatform();
    VideoPlayerPlatform.instance = fake;
    return fake;
  }

  /// The size the fake film reports, so `AspectRatio` has something to work
  /// with. Arbitrary — no test asserts it.
  static const Size _frameSize = Size(1920, 1440);

  /// How long the fake film claims to be.
  static const Duration _duration = Duration(seconds: 8);

  final Map<int, StreamController<VideoEvent>> _events = {};
  var _nextPlayerId = 1;

  /// Every volume set, in order. `0` is muted.
  final List<double> volumes = [];

  /// Whether looping was last switched on.
  bool? looping;

  /// How many times playback was asked to start.
  int plays = 0;

  /// Player ids that have been disposed.
  final List<int> disposed = [];

  @override
  Future<void> init() async {}

  @override
  Future<int?> createWithOptions(VideoCreationOptions options) async {
    final playerId = _nextPlayerId++;
    final controller = StreamController<VideoEvent>();
    _events[playerId] = controller;
    // The controller waits on an `initialized` event before it reports itself
    // ready, so it is delivered once the caller is listening.
    scheduleMicrotask(() {
      if (!controller.isClosed) {
        controller.add(
          VideoEvent(
            eventType: VideoEventType.initialized,
            duration: _duration,
            size: _frameSize,
          ),
        );
      }
    });
    return playerId;
  }

  @override
  Stream<VideoEvent> videoEventsFor(int playerId) => _events[playerId]!.stream;

  @override
  Future<void> setLooping(int playerId, bool value) async => looping = value;

  @override
  Future<void> setVolume(int playerId, double volume) async =>
      volumes.add(volume);

  @override
  Future<void> play(int playerId) async => plays++;

  @override
  Future<void> pause(int playerId) async {}

  @override
  Future<void> seekTo(int playerId, Duration position) async {}

  @override
  Future<void> setPlaybackSpeed(int playerId, double speed) async {}

  @override
  Future<Duration> getPosition(int playerId) async => Duration.zero;

  @override
  Future<void> dispose(int playerId) async {
    disposed.add(playerId);
    await _events.remove(playerId)?.close();
  }

  @override
  Widget buildView(int playerId) => const SizedBox.expand();

  @override
  Widget buildViewWithOptions(VideoViewOptions options) =>
      const SizedBox.expand();
}
