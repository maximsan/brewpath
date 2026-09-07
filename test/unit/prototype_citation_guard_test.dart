import 'package:flutter_test/flutter_test.dart';

import '../support/dart_sources.dart';

void main() {
  // The shapes the #479 sweep met: a `.jsx` or `.html` name, the design's one
  // `.js` by name (a `.js` class would flag this repo's own tools), and a line
  // number left behind after its file name was removed.
  final citation = RegExp(r'[\w-]+\.(?:jsx|html)|ds-content\.js|`:\d+`');

  const guardItself = 'test/unit/prototype_citation_guard_test.dart';

  test('no comment cites a prototype file', () {
    final offenders = <String>[
      for (final root in const ['lib', 'test', 'integration_test'])
        for (final file in dartSourcesUnder(root))
          if (file.path != guardItself)
            for (final comment in commentsIn(file.readAsStringSync()))
              if (citation.firstMatch(comment) case final hit?)
                '${file.path}  ${hit[0]}',
    ];

    expect(
      offenders,
      isEmpty,
      reason:
          "a comment may not name a prototype file. Quote the design's own "
          'value (`padding: 26px 24px`) or cite the ruling (an ADR or issue) '
          'instead. Found ${offenders.length}:\n${offenders.join('\n')}',
    );
  });
}
