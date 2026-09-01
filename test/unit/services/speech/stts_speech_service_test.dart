import 'package:brew_path/services/speech/speech_service.dart';
import 'package:brew_path/services/speech/stts_speech_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stts/stts.dart';

import '../../../support/fake_tts_platform.dart';

void main() {
  group('SttsSpeechService', () {
    test('speaks in the content language, not the device one', () async {
      final platform = FakeTtsPlatform.installed();

      await SttsSpeechService().speak('Arabica', languageTag: 'en-US');

      expect(platform.spoken, ['Arabica']);
      expect(platform.language, 'en-US');
    });

    test('flushes, so a second press restarts instead of queueing', () async {
      final platform = FakeTtsPlatform.installed();
      final service = SttsSpeechService();

      await service.speak('Arabica', languageTag: 'en-US');
      await service.speak('Arabica', languageTag: 'en-US');

      // `add` would stack a second reading behind the first — the design
      // cancels before every utterance (`dictionary.jsx:14`).
      expect(platform.modes, [TtsQueueMode.flush, TtsQueueMode.flush]);
    });

    test('reads a shade under natural pace', () async {
      final platform = FakeTtsPlatform.installed();

      await SttsSpeechService().speak('Doppio', languageTag: 'en-US');

      expect(platform.rate, 0.9);
    });

    test('cannot speak a language the device has no voice for', () async {
      FakeTtsPlatform.installed(languagesWithVoices: const ['fr-FR']);

      expect(await SttsSpeechService().canSpeak(contentLanguageTag), isFalse);
    });

    test('cannot speak where the platform offers no synthesizer', () async {
      FakeTtsPlatform.installed(supported: false);

      expect(await SttsSpeechService().canSpeak(contentLanguageTag), isFalse);
    });

    test('can speak when a voice exists for the content language', () async {
      FakeTtsPlatform.installed();

      expect(await SttsSpeechService().canSpeak(contentLanguageTag), isTrue);
    });

    test('stays quiet where the plugin is not registered', () async {
      FakeTtsPlatform.installed(unregistered: true);
      final service = SttsSpeechService();

      // A simulator, a test host, a platform we have not shipped to: the
      // channel throws on every call. A word that cannot play must not take
      // the screen — or the container's teardown — down with it.
      expect(await service.canSpeak(contentLanguageTag), isFalse);
      await expectLater(
        service.speak('Arabica', languageTag: contentLanguageTag),
        completes,
      );
      await expectLater(service.dispose(), completes);
    });
  });
}
