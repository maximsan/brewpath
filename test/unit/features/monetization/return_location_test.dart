import 'package:brew_path/features/monetization/domain/return_location.dart';
import 'package:flutter_test/flutter_test.dart';

// What the celebration's URL says about where it came from, and what it
// refuses to say.
void main() {
  Uri welcomeAt(String query) => Uri.parse('/purchase-welcome$query');

  test('carries the location the sale happened on', () {
    final query = returnQuery('/learn/lesson/m1l4');
    final welcome = welcomeAt('?$returnParam=%2Flearn%2Flesson%2Fm1l4');

    expect(query[returnParam], '/learn/lesson/m1l4');
    expect(returnLocationIn(welcome), '/learn/lesson/m1l4');
  });

  test('keeps the query a location of its own carries', () {
    final welcome = Uri.parse(
      '/purchase-welcome',
    ).replace(queryParameters: returnQuery('/cards?sort=newest'));

    expect(returnLocationIn(welcome), '/cards?sort=newest');
  });

  test('a welcome that names nowhere returns nothing', () {
    expect(returnLocationIn(welcomeAt('')), isNull);
    expect(returnLocationIn(welcomeAt('?$returnParam=')), isNull);
  });

  test('a route raised with no location carries no query', () {
    expect(returnQuery(null), isEmpty);
  });

  test('only an in-app location is taken', () {
    // A hand-written link, which the celebration must not follow out of the
    // app. `//host` is a URL without its scheme, not a path.
    expect(
      returnLocationIn(
        welcomeAt('?$returnParam=https%3A%2F%2Fevil.test'),
      ),
      isNull,
    );
    expect(
      returnLocationIn(welcomeAt('?$returnParam=%2F%2Fevil.test')),
      isNull,
    );
    expect(returnLocationIn(welcomeAt('?$returnParam=learn')), isNull);
  });
}
