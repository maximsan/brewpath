import 'package:brew_path/core/utils/date_utils.dart';
import 'package:brew_path/features/lessons/domain/replay_confirm.dart';
import 'package:flutter_test/flutter_test.dart';

final _today = DateTime(2026, 9, 20);
int _daysBefore(int days) => epochDay(_today) - days;

List<ReplayConfirmLine> _lines({
  int minutes = 4,
  int cards = 7,
  bool dayAlreadyEarned = false,
  int? lastCompletedDay,
}) => replayConfirmLines(
  minutes: minutes,
  cards: cards,
  dayAlreadyEarned: dayAlreadyEarned,
  lastCompletedDay: lastCompletedDay ?? _daysBefore(3),
  today: _today,
);

String _valueOf(List<ReplayConfirmLine> lines, String label) =>
    lines.firstWhere((line) => line.label == label).value;

void main() {
  group('the four lines', () {
    test('points never change, whatever the run does', () {
      expect(_valueOf(_lines(), 'Points'), 'No change');
      expect(
        _valueOf(_lines(dayAlreadyEarned: true), 'Points'),
        'No change',
      );
    });

    test('the streak line switches on whether the day is already earned', () {
      expect(_valueOf(_lines(), 'Streak'), ReplayConfirmCopy.streakCounts);
      expect(
        _valueOf(_lines(dayAlreadyEarned: true), 'Streak'),
        ReplayConfirmCopy.streakEarned,
      );
    });

    test('length gives the time and the card count', () {
      expect(
        _valueOf(_lines(minutes: 4, cards: 7), 'Length'),
        '~4 min · 7 cards',
      );
      expect(
        _valueOf(_lines(minutes: 2, cards: 1), 'Length'),
        '~2 min · 1 card',
      );
    });

    test('a lesson with no day on record shows three lines, not a blank', () {
      final lines = replayConfirmLines(
        minutes: 4,
        cards: 7,
        dayAlreadyEarned: false,
        lastCompletedDay: null,
        today: _today,
      );

      expect(lines.length, 3);
      expect(lines.any((line) => line.label == 'Last completed'), isFalse);
    });
  });

  group('naming the last run', () {
    test('names the days a learner can still place', () {
      expect(dayName(epochDay(_today), today: _today), 'Today');
      expect(dayName(_daysBefore(1), today: _today), 'Yesterday');
      // 2026-09-20 is a Sunday, so three days back is the Thursday.
      expect(dayName(_daysBefore(3), today: _today), 'Thursday');
    });

    test('falls back to the date once the weekday stops meaning one day', () {
      expect(dayName(_daysBefore(7), today: _today), 'Sun, Sep 13');
      expect(dayName(_daysBefore(87), today: _today), 'Thu, Jun 25');
    });
  });

  test('the title asks about the lesson by name', () {
    expect(
      ReplayConfirmCopy.title('Arabica vs Robusta'),
      'Arabica vs Robusta?',
    );
  });
}
