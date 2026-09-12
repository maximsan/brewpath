import 'package:brew_path/services/payments/revenue_cat_mapping.dart';
import 'package:brew_path/shared/models/monetization/plus_offering.dart';
import 'package:flutter_test/flutter_test.dart';

// Which RevenueCat offering means which arm. An arm with no offering name is
// an arm the dashboard can never put anybody on.
void main() {
  test('every arm has an offering the dashboard can name', () {
    expect(
      offeringArms.values.toSet(),
      MonetizationModel.values.toSet(),
    );
  });

  test('no two arms answer to the same offering', () {
    expect(offeringArms.values.length, offeringArms.values.toSet().length);
  });

  test('each offering name reaches its own arm', () {
    for (final entry in offeringArms.entries) {
      expect(armFor(entry.key), entry.value);
    }
  });

  test('an offering nobody recognises falls back to the baseline', () {
    // A dashboard rename must not leave a learner with no paywall at all.
    expect(armFor('experiment_47'), MonetizationModel.oneTime);
    expect(armFor(null), MonetizationModel.oneTime);
  });
}
