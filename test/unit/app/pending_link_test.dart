import 'package:brew_path/app/pending_link.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PendingLink', () {
    test('holds nothing until something is held', () {
      expect(PendingLink().take(), isNull);
    });

    test('gives the held target back once, then forgets it', () {
      final link = PendingLink()..hold('/cards/c1');

      // Once: the link is a one-shot instruction. Resolving it twice would
      // drag the learner back to the card every time they left it.
      expect(link.take(), '/cards/c1');
      expect(link.take(), isNull);
    });

    test('the first arrival wins', () {
      final link = PendingLink()
        ..hold('/cards/c1')
        ..hold('/learn');

      // The app navigates on its own while the onboarding gate is still
      // catching up, and that hop reaches `hold` exactly like an arrival
      // does. Keeping the first means the link the learner actually tapped
      // cannot be overwritten by the app walking past it.
      expect(link.take(), '/cards/c1');
    });
  });
}
