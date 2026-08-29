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

  group('monthYear', () {
    test('names the month in full, beside the year', () {
      expect(monthYear(DateTime(2026, 5, 8)), 'May 2026');
      expect(monthYear(DateTime(2026)), 'January 2026');
      expect(monthYear(DateTime(2025, 12, 31)), 'December 2025');
    });
  });
}
