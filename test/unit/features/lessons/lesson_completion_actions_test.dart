import 'package:brew_path/features/lessons/domain/lesson_completion_actions.dart';
import 'package:brew_path/features/lessons/domain/lesson_destination.dart';
import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:flutter_test/flutter_test.dart';

CompletionActions _actions({MasteryBand? band, String? nextLessonId}) =>
    completionActions(
      lessonId: 'm1l1',
      band: band,
      nextLessonId: nextLessonId,
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

    // There is no module case. A run that closes its module branches to the
    // module ending and never reaches this screen (#458), so the rule has two
    // outcomes rather than three — and no label to invent for a moment the
    // design gives the lesson ending no word for.
    test('never routes to a module recap, whatever the run did', () {
      for (final actions in [
        _actions(band: MasteryBand.perfect, nextLessonId: 'm2l1'),
        _actions(band: MasteryBand.needsPractice),
        _actions(),
      ]) {
        expect(actions.destination, isNot(moduleSummary('m1')));
      }
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

    test('an unscored run is not treated as weak', () {
      expect(_actions(nextLessonId: 'm1l2').link?.label, backToPathLabel);
    });
  });
}
