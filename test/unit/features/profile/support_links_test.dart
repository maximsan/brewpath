import 'package:brew_path/features/profile/domain/support_links.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('the mailbox a learner writes to', () {
    test('opens a composer addressed to the support mailbox', () {
      final mail = supportMailto('hi@brewpath.app');

      expect(mail.scheme, 'mailto');
      expect(mail.path, 'hi@brewpath.app');
    });

    test('carries no subject, because the learner sets it', () {
      expect(supportMailto('hi@brewpath.app').query, isEmpty);
    });
  });

  group('a problem report names the build it came from', () {
    test('carries the version in the subject', () {
      final mail = problemReportMailto('hi@brewpath.app', '1.4.0+22');

      expect(mail.scheme, 'mailto');
      expect(mail.path, 'hi@brewpath.app');
      expect(mail.queryParameters['subject'], contains('1.4.0+22'));
    });

    test('goes to the same mailbox as plain support', () {
      expect(
        problemReportMailto('hi@brewpath.app', '1.0.0+1').path,
        supportMailto('hi@brewpath.app').path,
      );
    });

    test('says what it is, so an inbox can sort it', () {
      final subject = problemReportMailto(
        'hi@brewpath.app',
        '1.0.0+1',
      ).queryParameters['subject']!;

      expect(subject.toLowerCase(), contains('problem'));
    });

    test('an unknown version still produces a usable composer', () {
      // The version arrives from a plugin and can be null on the first frame;
      // a report that cannot name its build is better than no composer.
      final mail = problemReportMailto('hi@brewpath.app', null);

      expect(mail.scheme, 'mailto');
      expect(mail.path, 'hi@brewpath.app');
      expect(mail.queryParameters['subject'], isNotEmpty);
    });

    test('escapes a subject the URI would otherwise break on', () {
      final mail = problemReportMailto('hi@brewpath.app', '1.0.0+1');

      expect(mail.toString(), isNot(contains(' ')));
    });
  });
}
