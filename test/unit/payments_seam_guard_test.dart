import 'package:flutter_test/flutter_test.dart';

import '../support/dart_sources.dart';

/// Entitlement is a seam, and this is what makes that structural.
///
/// #89 required that feature code be *"unable to reach the payments service"*,
/// **structural rather than a convention**. It shipped as a convention: the
/// purchase controller sits under `lib/features/` like everything else and
/// imports the service, and nothing stopped the next feature doing the same.
/// A seam nothing enforces stops being a seam the first time somebody is in a
/// hurry.
///
/// The same crude shape as the overlay and sheet guards: read the sources.
void main() {
  /// The layer that owns acquisition. Named explicitly rather than matched by
  /// prefix — a new folder under `features/` must not inherit the exemption by
  /// being created.
  const monetizationLayer = <String>{
    'lib/features/monetization/domain/course_entitlement.dart',
    'lib/features/monetization/domain/plus_purchase_controller.dart',
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
}
