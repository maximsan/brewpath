import 'package:brew_path/core/constants/app_labels.dart';
import 'package:brew_path/features/lessons/domain/lesson_completion_actions.dart';
import 'package:brew_path/features/lessons/domain/lesson_destination.dart';
import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:flutter_test/flutter_test.dart';

CompletionActions _actions({
  MasteryBand? band,
  String? nextLessonId,
  String? moduleSummaryId,
}) => completionActions(
  lessonId: 'm1l1',
  continueLabel: AppLabels.continueLabel,
  band: band,
  nextLessonId: nextLessonId,
  moduleSummaryId: moduleSummaryId,
);

void main() {
  group('the primary action', () {
    test('offers the next lesson when one is playable', () {
      final actions = _actions(band: MasteryBand.perfect, nextLessonId: 'm1l2');

      expect(actions.label, nextLessonLabel);
      expect(actions.destination, lessonRun('m1l2'));
    });

    test('returns to Path when the course has nothing queued', () {
      final actions = _actions(band: MasteryBand.perfect);

      expect(actions.label, backToPathLabel);
      expect(actions.destination, pathTab);
    });

    // Path, not Today: the course moved onto that tab, so the label and the
    // destination have to agree about where "Path" is.
    test('Back to Path is not the Today tab', () {
      expect(_actions().destination, isNot(learnTab));
    });

    test('a run that closed its module continues to the module recap', () {
      final actions = _actions(
        band: MasteryBand.perfect,
        nextLessonId: 'm2l1',
        moduleSummaryId: 'm1',
      );

      expect(actions.label, AppLabels.continueLabel);
      expect(actions.destination, moduleSummary('m1'));
    });
  });

  group('the quiet link', () {
    test('a weak run is invited to practise', () {
      final actions = _actions(
        band: MasteryBand.needsPractice,
        nextLessonId: 'm1l2',
      );

      expect(actions.link?.label, practiceAgainLabel);
      expect(actions.link?.destination, lessonRun('m1l1'));
    });

    // The design drops the plain return beside the invitation, so a weak run
    // is asked to practise rather than handed two ways out.
    test('and is not also offered the way back', () {
      expect(
        _actions(
          band: MasteryBand.needsPractice,
          nextLessonId: 'm1l2',
        ).link?.label,
        isNot(backToPathLabel),
      );
    });

    test('a strong run with a next lesson keeps the way back', () {
      final actions = _actions(
        band: MasteryBand.mastered,
        nextLessonId: 'm1l2',
      );

      expect(actions.link?.label, backToPathLabel);
      expect(actions.link?.destination, pathTab);
    });

    test('a strong run with nothing queued gets no link at all', () {
      expect(_actions(band: MasteryBand.perfect).link, isNull);
    });

    // The invitation survives the module moment: closing a module and needing
    // practice are independent, and only the primary action is the module's.
    test('a weak run that closed a module keeps the invitation', () {
      final actions = _actions(
        band: MasteryBand.needsPractice,
        moduleSummaryId: 'm1',
      );

      expect(actions.destination, moduleSummary('m1'));
      expect(actions.link?.label, practiceAgainLabel);
    });

    test('an unscored run is not treated as weak', () {
      expect(_actions(nextLessonId: 'm1l2').link?.label, backToPathLabel);
    });
  });
}
