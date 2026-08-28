import 'package:flutter_test/flutter_test.dart';

import '../support/dart_sources.dart';

/// The app has two footers, and only two.
///
/// The design system states it outright for the sticky action bar: *"this and
/// the tab bar are the app's only footers."* A rule like that is worth a guard
/// rather than a reviewer's memory — the sheet primitive's own rule lasted
/// exactly until the second sheet before it was broken, and this one has six
/// screens queued up to test it (#382, #384, #230, #398 and the course ending).
///
/// **Deliberately crude**, like the sheet guard it copies: it matches the
/// property name anywhere in the file, comments included. No source outside the
/// shell has a reason to name a footer slot, and if one ever does, rewording it
/// is the right fix.
void main() {
  /// The one file allowed to mount the tab bar: the shell itself.
  const shell = 'lib/app/app_shell.dart';

  test('only the shell mounts a bottom navigation bar', () {
    final offenders = dartSourcesUnder('lib')
        .where((file) => file.path != shell)
        .where(
          (file) => file.readAsStringSync().contains('bottomNavigationBar:'),
        )
        .map((file) => file.path)
        .toList();

    expect(
      offenders,
      isEmpty,
      reason:
          "the tab bar is the shell's ($shell). A screen that wants a pinned "
          'action takes StickyActionBar instead. Found:\n'
          '${offenders.join('\n')}',
    );
  });

  test('nothing uses Scaffold.persistentFooterButtons', () {
    // Material's third footer slot. It is not in the design at all, and it
    // would sit below a sticky action bar rather than instead of one.
    final offenders = dartSourcesUnder('lib')
        .where(
          (file) => file.readAsStringSync().contains('persistentFooterButtons'),
        )
        .map((file) => file.path)
        .toList();

    expect(
      offenders,
      isEmpty,
      reason:
          'a third footer is not in the design — the sticky action bar '
          "carries a screen's one action. Found:\n"
          '${offenders.join('\n')}',
    );
  });
}
