import 'package:flutter_test/flutter_test.dart';

import '../support/dart_sources.dart';

// No screen draws Material's bar. Fifteen answered that their own way (#513),
// and the six full-screen flows that were exempted while the floating bar was
// unbuilt now wear it too (#525). The sweep is a one-off; this keeps it swept.
void main() {
  test('no page opened from a tab hand-rolls a bar', () {
    final offenders = dartSourcesUnder('lib')
        .where(
          (file) =>
              withoutComments(file.readAsStringSync()).contains('AppBar('),
        )
        .map((file) => file.path)
        .toList();

    expect(
      offenders,
      isEmpty,
      reason:
          'a pushed page goes through SubScreenScaffold, which carries the '
          "design's bar, the scroll flag and the room the scroll leaves for "
          'it. A stock AppBar is a solid strip that never gets out of the '
          'way, and it is not what the design draws. Found:\n'
          '${offenders.join('\n')}',
    );
  });
}
