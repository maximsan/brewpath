import 'package:brew_path/core/utils/date_utils.dart';
import 'package:brew_path/features/progress/domain/joined_date.dart';
import 'package:flutter_test/flutter_test.dart';

/// The rule behind Profile's closing line: the recorded start of the account,
/// and what stands in for it on a device that predates the record.
void main() {
  final march = DateTime(2026, 3, 14);
  final july = DateTime(2026, 7, 2);

  test('the recorded start is the joined date', () {
    expect(deriveJoinedDate(installedAt: march, activeDays: const {}), march);
  });

  test('the recorded start wins over a later first active day', () {
    // The case the whole ticket is about: someone who installed in March and
    // did not start until July joined in March, not July.
    expect(
      deriveJoinedDate(installedAt: march, activeDays: {epochDay(july)}),
      march,
    );
  });

  test('an active day older than the stamp wins over it', () {
    // The same rule read the other way, and the reason this is a minimum
    // rather than a ranking: a restored snapshot can carry days from before
    // this copy of the app existed, and they are older evidence than any
    // stamp. Ranking the stamp first would move the line *later* than it read
    // before the stamp existed.
    expect(
      deriveJoinedDate(installedAt: july, activeDays: {epochDay(march)}),
      march,
    );
  });

  test('the stamp is reduced to its calendar day', () {
    // Both sources have to come back the same shape; the line names a month,
    // and a caller comparing two results should not find one carrying a time.
    expect(
      deriveJoinedDate(
        installedAt: DateTime(2026, 3, 14, 9, 30),
        activeDays: const {},
      ),
      march,
    );
  });

  test('the earliest active day stands in when nothing was recorded', () {
    // Every device installed before the stamp shipped: the migration does not
    // back-date them, so the first day they did anything is the closest thing
    // that is actually true.
    expect(
      deriveJoinedDate(
        installedAt: null,
        activeDays: {epochDay(july), epochDay(march)},
      ),
      march,
    );
  });

  test('nothing known reads as nothing, never as today', () {
    expect(deriveJoinedDate(installedAt: null, activeDays: const {}), isNull);
  });
}
