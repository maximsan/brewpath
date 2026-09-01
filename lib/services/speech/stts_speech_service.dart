import 'package:brew_path/services/speech/speech_service.dart';
import 'package:stts/stts.dart';

/// The platform's own synthesizer, through `stts` (ADR-0012).
///
/// `stts` reaches `AVSpeechSynthesizer` on iOS with its audio session kept
/// separate from the app's, so speaking a term does not interrupt the Welcome
/// film. Nothing leaves the device.
///
/// Every call is guarded, as the design's own `speakTerm` is
/// (`dictionary.jsx:10`): a host with no synthesizer registered — a simulator,
/// a test, a platform we have not shipped to — answers with a thrown channel
/// error, and a pronunciation that cannot play must never take a screen down
/// with it.
class SttsSpeechService implements SpeechService {
  /// Creates a [SttsSpeechService].
  SttsSpeechService([Tts? tts]) : _tts = tts ?? Tts();

  final Tts _tts;

  /// The reading pace the design sets on its utterance (`dictionary.jsx:13`) —
  /// a shade under natural, because these are unfamiliar words being taught.
  static const double _rate = 0.9;

  @override
  Future<bool> canSpeak(String languageTag) async {
    try {
      if (!await _tts.isSupported()) return false;
      final voices = await _tts.getVoicesByLanguage(languageTag);
      return voices.isNotEmpty;
    } on Exception {
      return false;
    }
  }

  @override
  Future<void> speak(String text, {required String languageTag}) async {
    try {
      await _tts.setLanguage(languageTag);
      await _tts.setRate(_rate);
      // `flush` is the design's `cancel()`: a second press restarts the word
      // instead of stacking another reading behind it.
      await _tts.start(
        text,
        options: const TtsOptions(mode: TtsQueueMode.flush),
      );
    } on Exception {
      // Nothing to recover: the word simply does not play.
    }
  }

  @override
  Future<void> dispose() async {
    try {
      await _tts.dispose();
    } on Exception {
      // Releasing a synthesizer that was never registered is not a failure.
    }
  }
}
