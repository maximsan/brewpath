import 'package:flutter_test/flutter_test.dart';

import '../support/dart_sources.dart';

/// Every sheet opens through the primitive.
///
/// The chrome a sheet wears — mood background, dimmed barrier, chrome-radius
/// corners, handle, safe area, height cap, title and reduced motion — is
/// identical across all nine sheet types the design specifies, which is why one
/// function serves them all (#234). A sheet opened any other way inherits none
/// of it.
///
/// **This guard exists because the rule was already broken once.** The app's
/// first sheet was documented and styled, and carried a comment saying in as
/// many words that *"the second one is what will show which parts are shared"*.
/// The second one — the dictionary's term peek (#231) — was written raw against
/// `showModalBottomSheet` anyway, reimplementing the height cap and inheriting
/// no styling at all. A rule stated as "every sheet" and enforced nowhere lasts
/// until the fourth sheet.
///
/// A sweep is a one-off; this is the guard that keeps it swept — the same shape
/// as the points-vocabulary and companion-payout guards.
///
/// **Deliberately crude**, like the helper it reads sources with: it matches
/// the call's name anywhere in the file, comments included. After the migration
/// no source in `lib/` has a reason to name the door it must not use, and if
/// one ever does, rewording it is the right fix.
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
