import 'package:brew_path/services/speech/speech_service.dart';

/// A [SpeechService] that never speaks.
///
/// Stands in wherever the platform has no synthesizer to offer — the widget
/// tests, and any host where `stts` reports no voice.
class NoOpSpeechService implements SpeechService {
  /// Creates a [NoOpSpeechService].
  const NoOpSpeechService();

  @override
  Future<bool> canSpeak(String languageTag) async => false;

  @override
  Future<void> speak(String text, {required String languageTag}) async {}

  @override
  Future<void> dispose() async {}
}
