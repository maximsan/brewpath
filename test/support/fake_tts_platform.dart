import 'package:flutter/services.dart';
import 'package:stts/stts.dart';

/// A [TtsPlatformInterface] that speaks nothing and records what it was asked.
///
/// `stts` reaches the platform's synthesizer through a method channel, which
/// `flutter_tester` does not register — so without this, every call throws and
/// `SttsSpeechService` cannot be tested at all. Installing it here exercises
/// the real service: the language it sets, the rate, and the queue mode that
/// decides whether a second press restarts or stacks.
class FakeTtsPlatform implements TtsPlatformInterface {
  /// Creates a [FakeTtsPlatform] and installs it as the platform under test.
  factory FakeTtsPlatform.installed({
    bool supported = true,
    bool unregistered = false,
    List<String> languagesWithVoices = const ['en-US'],
  }) {
    final fake = FakeTtsPlatform._(
      supported: supported,
      unregistered: unregistered,
      languagesWithVoices: languagesWithVoices,
    );
    TtsPlatformInterface.instance = fake;
    return fake;
  }

  FakeTtsPlatform._({
    required this.supported,
    required this.unregistered,
    required this.languagesWithVoices,
  });

  /// Whether to answer every call the way an unregistered plugin does.
  final bool unregistered;

  /// Whether the platform claims a synthesizer at all.
  final bool supported;

  /// The languages this device has a voice for.
  final List<String> languagesWithVoices;

  /// Every utterance started, in order.
  final List<String> spoken = <String>[];

  /// The queue mode each utterance was started with.
  final List<TtsQueueMode> modes = <TtsQueueMode>[];

  /// The last language set.
  String? language;

  /// The last rate set.
  double? rate;

  void _guard() {
    if (unregistered) {
      throw MissingPluginException('No implementation found for method');
    }
  }

  @override
  Future<bool> isSupported() async {
    _guard();
    return supported;
  }

  @override
  Future<void> start(
    String text, {
    TtsOptions options = const TtsOptions(),
  }) async {
    _guard();
    spoken.add(text);
    modes.add(options.mode);
  }

  @override
  Future<void> setLanguage(String language) async => this.language = language;

  @override
  Future<void> setRate(double rate) async => this.rate = rate;

  @override
  Future<List<TtsVoice>> getVoicesByLanguage(String language) async =>
      languagesWithVoices.contains(language)
      ? [
          TtsVoice(
            id: '$language-voice',
            language: language,
            languageInstalled: true,
            name: 'Test voice',
            networkRequired: false,
            gender: TtsVoiceGender.unspecified,
          ),
        ]
      : [];

  @override
  Future<void> stop() async {}

  @override
  Future<void> pause() async {}

  @override
  Future<void> resume() async {}

  @override
  Future<String> getLanguage() async => language ?? '';

  @override
  Future<List<String>> getLanguages() async => languagesWithVoices;

  @override
  Future<void> setVoice(String voiceId) async {}

  @override
  Future<List<TtsVoice>> getVoices() async => [];

  @override
  Future<void> setPitch(double pitch) async {}

  @override
  Future<void> setVolume(double volume) async {}

  @override
  Future<void> dispose() async => _guard();

  @override
  Stream<TtsState> get onStateChanged => const Stream.empty();
}
