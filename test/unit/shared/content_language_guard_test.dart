// The app must never offer a language it has only half of. ADR-0026 makes
// "complete" the bar for offering one, and the two halves are switched by
// different machinery — the app's own words by Flutter's locale resolution,
// the course text by ContentLanguage — so nothing but this stops them drifting
// apart the day a second .arb lands.
import 'package:brew_path/l10n/generated/app_localizations.dart';
import 'package:brew_path/shared/content/content_language.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every language the course text can be read in.
const _courseLanguages = <ContentLanguage>[ContentLanguage.english];

void main() {
  test('every language the app offers has course text to match', () {
    final courseCodes = {for (final it in _courseLanguages) it.code};

    for (final locale in AppLocalizations.supportedLocales) {
      expect(
        courseCodes,
        contains(locale.languageCode),
        reason:
            'lib/l10n/app_${locale.languageCode}.arb offers '
            '${locale.languageCode} to anyone whose phone is set to it, but '
            'the course has no ${locale.languageCode} folder — that is the '
            'mixed-language app ADR-0008 forbids. Add the content folder and '
            'a ContentLanguage for it, or drop the .arb.',
      );
    }
  });

  test('the language this build reads is one the app offers', () {
    expect(
      AppLocalizations.supportedLocales.map((it) => it.languageCode),
      contains(activeContentLanguage.code),
    );
  });

  test('only the master reads its banks without a folder over them', () {
    for (final language in _courseLanguages) {
      final path = translatedBankPath('lessons', language);
      expect(path == null, language.isMaster, reason: language.code);
    }
  });
}
