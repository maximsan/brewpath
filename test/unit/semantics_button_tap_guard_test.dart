import 'package:flutter_test/flutter_test.dart';

import '../support/dart_sources.dart';

// `excludeSemantics: true` drops the descendants' semantics, which is the
// point — the label is read once instead of once per line inside it. It drops
// the child's tap action along with the text, so a node that also says
// `button: true` announces a button that cannot be pressed (#487). The flag
// and the action have to be written together, and this reads the sources to
// keep them that way.
void main() {
  /// A value that is written but switched off, so the flag is not claimed.
  bool claims(String? argument) => argument != null && argument != 'false';

  test('a node that says button and hides its child carries a tap', () {
    final offenders = <String>[];
    for (final file in dartSourcesUnder('lib')) {
      for (final call in semanticsCallsIn(file.readAsStringSync())) {
        final arguments = call.arguments;
        if (!claims(arguments['button'])) continue;
        if (!claims(arguments['excludeSemantics'])) continue;
        if (claims(arguments['onTap'])) continue;
        offenders.add('${file.path}:${call.line}');
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'each of these announces a button a screen reader cannot press: the '
          'flag is set and the tap it needs was excluded with the text. Pass '
          'the handler to the Semantics as well as to the InkWell. Found:\n'
          '${offenders.join('\n')}',
    );
  });

  test('the scan reaches the buttons it is meant to read', () {
    final buttons = dartSourcesUnder('lib')
        .expand((file) => semanticsCallsIn(file.readAsStringSync()))
        .where((call) => claims(call.arguments['button']));

    expect(
      buttons,
      isNotEmpty,
      reason: 'a guard that reads nothing passes for the wrong reason',
    );
  });
}
