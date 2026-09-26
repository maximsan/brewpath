import 'package:brew_path/features/lessons/presentation/lesson_completion_beat.dart';
import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:brew_path/l10n/generated/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('the beat opens on what the run did', () {
    test('a clean run', () {
      expect(
        completionBeatTitle(AppLocalizationsEn(), MasteryBand.perfect),
        'Perfect run!',
      );
    });

    test('one mistake', () {
      expect(
        completionBeatTitle(AppLocalizationsEn(), MasteryBand.mastered),
        'Mastered it.',
      );
    });

    // Congratulated, not corrected: the invitation to replay is carried by the
    // chip and the link further down.
    test('a weak run is still opened warmly', () {
      expect(
        completionBeatTitle(AppLocalizationsEn(), MasteryBand.needsPractice),
        'Good start.',
      );
    });

    test('a run with no stored score falls to the neutral line', () {
      expect(completionBeatTitle(AppLocalizationsEn(), null), 'Nice work.');
    });

    test('every band has a line of its own', () {
      final lines = {
        for (final band in MasteryBand.values)
          completionBeatTitle(AppLocalizationsEn(), band),
      };
      expect(lines, hasLength(MasteryBand.values.length));
      expect(
        lines,
        isNot(contains(completionBeatTitle(AppLocalizationsEn(), null))),
      );
    });
  });

  group('the kicker', () {
    test('a first completion', () {
      expect(
        completionEyebrow(AppLocalizationsEn(), isReplay: false),
        AppLocalizationsEn().completionEyebrowComplete,
      );
    });

    // The app keeps the two apart where the design has one path: a replay pays
    // nothing, and the kicker is the only thing that says so once the rail has
    // no rows to draw.
    test('a replay', () {
      expect(
        completionEyebrow(AppLocalizationsEn(), isReplay: true),
        AppLocalizationsEn().completionEyebrowReview,
      );
    });
  });
}
