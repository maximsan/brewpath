import 'package:brew_path/core/utils/date_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('dateFromEpochDay', () {
    test('is the inverse of epochDay for a local calendar day', () {
      for (final date in [
        DateTime(2026, 5, 8),
        DateTime(2026),
        DateTime(2026, 12, 31),
        DateTime(2024, 2, 29),
      ]) {
        expect(dateFromEpochDay(epochDay(date)), date, reason: '$date');
      }
    });

    test('drops the time of day, like the scheme it reads', () {
      final noon = DateTime(2026, 5, 8, 12, 34, 56);

      expect(dateFromEpochDay(epochDay(noon)), DateTime(2026, 5, 8));
    });
  });

  group('shortDate', () {
    test('shortens the day and the month to three letters', () {
      expect(shortDate(DateTime(2026, 5, 8)), 'Fri, May 8');
      expect(shortDate(DateTime(2026, 9, 11)), 'Fri, Sep 11');
      expect(shortDate(DateTime(2026)), 'Thu, Jan 1');
    });

    test('the long form is untouched, for Term of the Day', () {
      expect(longDate(DateTime(2026, 5, 8)), 'Friday, May 8');
    });
  });

  group('monthYear', () {
    test('names the month in full, beside the year', () {
      expect(monthYear(DateTime(2026, 5, 8)), 'May 2026');
      expect(monthYear(DateTime(2026)), 'January 2026');
      expect(monthYear(DateTime(2025, 12, 31)), 'December 2025');
    });
  });
}
