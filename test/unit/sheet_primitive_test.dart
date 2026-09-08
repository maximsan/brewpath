import 'package:flutter_test/flutter_test.dart';

import '../support/dart_sources.dart';

// Every sheet opens through the primitive: the chrome all nine sheet types
// share is why one function serves them all (#234), and a sheet opened any
// other way inherits none of it. The rule was stated for the first sheet and
// broken by the second (#231), so it is enforced here rather than remembered.
// Deliberately crude: it matches the call's name anywhere in the file, comments
// included, because no source in `lib/` may name the door it must not use.
void main() {
  /// The one file allowed to open a raw sheet: the primitive itself.
  const primitive = 'lib/core/widgets/app_sheet.dart';

  test('no source outside the primitive opens a bottom sheet directly', () {
    // Both doors, because the primitive now pushes the route itself: a sheet
    // needs the dim's blur as well as its colour, and only a route can carry
    // one (#379).
    final offenders = dartSourcesUnder('lib')
        .where((file) => file.path != primitive)
        .where(
          (file) => const [
            'showModalBottomSheet',
            'ModalBottomSheetRoute',
          ].any(file.readAsStringSync().contains),
        )
        .map((file) => file.path)
        .toList();

    expect(
      offenders,
      isEmpty,
      reason:
          'sheets open through showAppSheet ($primitive), which carries the '
          'chrome, the title and reduced motion. Found:\n'
          '${offenders.join('\n')}',
    );
  });
}
