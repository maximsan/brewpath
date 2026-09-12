import 'package:brew_path/features/monetization/domain/purchase_welcome_return.dart';
import 'package:flutter_test/flutter_test.dart';

// What the celebration's URL says about where it came from, and what it
// refuses to say.
void main() {
  Uri welcomeAt(String query) => Uri.parse('/purchase-welcome$query');

  test('carries the location the sale happened on', () {
    final query = welcomeReturnTo('/learn/lesson/m1l4');
    final welcome = welcomeAt('?$welcomeReturnParam=%2Flearn%2Flesson%2Fm1l4');

    expect(query[welcomeReturnParam], '/learn/lesson/m1l4');
    expect(welcomeReturnIn(welcome), '/learn/lesson/m1l4');
  });

  test('keeps the query a location of its own carries', () {
    final welcome = Uri.parse(
      '/purchase-welcome',
    ).replace(queryParameters: welcomeReturnTo('/cards?sort=newest'));

    expect(welcomeReturnIn(welcome), '/cards?sort=newest');
  });

  test('a welcome that names nowhere returns nothing', () {
    expect(welcomeReturnIn(welcomeAt('')), isNull);
    expect(welcomeReturnIn(welcomeAt('?$welcomeReturnParam=')), isNull);
  });

  test('only an in-app location is taken', () {
    // A hand-written link, which the celebration must not follow out of the
    // app. `//host` is a URL without its scheme, not a path.
    expect(
      welcomeReturnIn(
        welcomeAt('?$welcomeReturnParam=https%3A%2F%2Fevil.test'),
      ),
      isNull,
    );
    expect(
      welcomeReturnIn(welcomeAt('?$welcomeReturnParam=%2F%2Fevil.test')),
      isNull,
    );
    expect(welcomeReturnIn(welcomeAt('?$welcomeReturnParam=learn')), isNull);
  });
}
