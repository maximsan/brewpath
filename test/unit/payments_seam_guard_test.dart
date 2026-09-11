import 'package:flutter_test/flutter_test.dart';

import '../support/dart_sources.dart';

// #89 asked that feature code be structurally unable to reach the payments
// service; it shipped as a convention, with the purchase controller sitting
// under `lib/features/` and importing the service like anything else. A seam
// nothing enforces stops being a seam the first time somebody is in a hurry,
// so this reads the sources — the same crude shape as the overlay and sheet
// guards.
void main() {
  /// The layer that owns acquisition. Named explicitly rather than matched by
  /// prefix — a new folder under `features/` must not inherit the exemption by
  /// being created.
  const monetizationLayer = <String>{
    'lib/features/monetization/domain/course_entitlement.dart',
    'lib/features/monetization/domain/paywall_view.dart',
    'lib/features/monetization/domain/paywall_view_provider.dart',
    'lib/features/monetization/domain/plus_offering_provider.dart',
    'lib/features/monetization/domain/plus_purchase_controller.dart',
  };

  /// The paywall's own layer: the only thing that may know which arm sold a
  /// purchase. Everything else asks whether the learner has Plus, full stop —
  /// so this list grows when the paywall does, and never otherwise.
  const paywallLayer = <String>{
    'lib/features/monetization/config/paywall_config.dart',
    'lib/features/monetization/config/paywall_copy.dart',
    'lib/features/monetization/domain/foundations_faq_tail.dart',
    'lib/features/monetization/domain/paywall_view.dart',
    'lib/features/monetization/domain/paywall_view_provider.dart',
    'lib/features/monetization/domain/plus_offering_provider.dart',
    'lib/features/monetization/domain/plus_purchase_controller.dart',
    'lib/features/monetization/domain/purchased_term.dart',
    'lib/features/monetization/presentation/paywall_screen.dart',
    'lib/features/monetization/presentation/plan_picker.dart',
    'lib/features/monetization/presentation/plus_gate_sheet.dart',
    'lib/features/monetization/presentation/purchase_welcome_route.dart',
  };

  test('only the monetization layer imports the payments service', () {
    final offenders = dartSourcesUnder('lib/features')
        .where((file) => !monetizationLayer.contains(file.path))
        .where(
          (file) => withoutComments(
            file.readAsStringSync(),
          ).contains('services/payments'),
        )
        .map((file) => file.path)
        .toList();

    expect(
      offenders,
      isEmpty,
      reason:
          'features ask courseEntitlementProvider whether the learner has '
          'Plus; they never reach past it to the store. Adding a file to the '
          'list above is adding a second place that knows how purchases work, '
          'which is the thing the seam exists to prevent. Found:\n'
          '${offenders.join('\n')}',
    );
  });

  test('the layer that may is exactly the layer that does', () {
    // A stale allow-list is a hole: a file that stops importing the service
    // leaves an exemption behind for whatever is written there next.
    final unused = monetizationLayer.where(
      (path) => !dartSourcesUnder('lib/features').any(
        (file) =>
            file.path == path &&
            withoutComments(
              file.readAsStringSync(),
            ).contains('services/payments'),
      ),
    );

    expect(
      unused,
      isEmpty,
      reason:
          'these are exempted from the payments rule and no longer need to '
          'be. Remove them:\n${unused.join('\n')}',
    );
  });

  test('no access check can see which arm the learner is on', () {
    // #176's load-bearing claim. An entitlement that branched on the model
    // would make the same purchase mean different things on different arms,
    // and the experiment could not end without a migration.
    final offenders = dartSourcesUnder('lib')
        .where((file) => !paywallLayer.contains(file.path))
        .where((file) => !file.path.startsWith('lib/services/payments/'))
        .where(
          (file) => withoutComments(
            file.readAsStringSync(),
          ).contains('plus_offering'),
        )
        .map((file) => file.path)
        .toList();

    expect(
      offenders,
      isEmpty,
      reason:
          'the monetization model reaches the paywall and stops there. A file '
          'that reads it is a file whose behaviour changes per arm, which is '
          'what the seam exists to prevent. Found:\n${offenders.join('\n')}',
    );
  });
}
