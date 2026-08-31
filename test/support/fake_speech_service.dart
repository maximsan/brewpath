import 'package:brew_path/services/speech/speech_service.dart';

/// A [SpeechService] that records what it was asked to say.
///
/// The widget tests care about the call, not the sound: "pressing the speaker
/// speaks the term" is a claim about one method reaching the service with the
/// right word.
class FakeSpeechService implements SpeechService {
  /// Creates a [FakeSpeechService], optionally with no voice to offer.
  FakeSpeechService({this.hasVoice = true});

  /// Whether the device claims a voice for the language asked about.
  final bool hasVoice;

  /// Every word spoken, in order.
  final List<String> spoken = <String>[];

  @override
  Future<bool> canSpeak(String languageTag) async => hasVoice;

  @override
  Future<void> speak(String text, {required String languageTag}) async =>
      spoken.add(text);

  @override
  Future<void> dispose() async {}
}
