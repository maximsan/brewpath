import 'package:brew_path/services/speech/speech_service.dart';
import 'package:brew_path/services/speech/stts_speech_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'speech_providers.g.dart';

/// The app's voice.
///
/// Overridden with `NoOpSpeechService` in tests, so nothing reaches a platform
/// channel that `flutter_tester` does not register.
@riverpod
SpeechService speechService(Ref ref) {
  final service = SttsSpeechService();
  ref.onDispose(service.dispose);
  return service;
}

/// Whether this device can speak the content's language.
///
/// Asked once and cached, because the answer is a property of the device and
/// its installed voices, not of the term being read.
@riverpod
Future<bool> canSpeakContentLanguage(Ref ref) =>
    ref.watch(speechServiceProvider).canSpeak(contentLanguageTag);
