import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/guard_tests.dart';

/// Where the sweep is spent, and what has to keep calling it.
const _hook = 'tool/git-hooks/pre-push';
const _selector = 'tool/guard_tests.dart';

/// The four ways a test writes the path it reads. The last two are not
/// hypothetical: a wrapped call and a path held in a `const` were both missed
/// by a matcher that only looked inside `File(…)`.
const _spellings = <String, String>{
  'in the call': "File('lib/x.dart').read();",
  'wrapped by the formatter': "File(\n  'lib/x.dart',\n).read();",
  'in double quotes': 'File("lib/x.dart").read();',
  'held in a const': "const dir = 'lib/x.dart';\nFile(dir).read();",
};

void main() {
  test('it names tests that exist, and some of them', () {
    final swept = guardTestPaths();

    expect(swept, isNotEmpty);
    for (final path in swept) {
      expect(File(path).existsSync(), isTrue, reason: '$path is not a file');
    }
  });

  test('the pre-push hook sweeps by this list rather than by a name', () {
    // The bug this replaces: the hook picked guards with `find -name` and
    // thirteen of them were not named that way (#662). A hook that stops
    // asking this file is that bug again.
    final hook = File(_hook).readAsStringSync();

    expect(hook, contains(_selector));
    expect(
      hook,
      isNot(contains("-name '*_guard_test.dart'")),
      reason: 'the filename convention is what stopped guarding',
    );
  });

  test('a path is seen however the test writes it', () {
    for (final spelling in _spellings.entries) {
      expect(
        repoRootsNamed(spelling.value),
        contains('lib/'),
        reason: 'a guard that names its path ${spelling.key} is missed',
      );
    }
  });

  test('a comment naming a path is not a test reading one', () {
    expect(repoRootsNamed("// see 'lib/x.dart' for why\n"), isEmpty);
  });

  test('nothing declared a guard by its name is excluded', () {
    expect(
      notGuards.keys.where((path) => path.endsWith('_guard_test.dart')),
      isEmpty,
      reason: 'a file that calls itself a guard cannot be quietly dropped',
    );
  });

  test('every exclusion still names a file, and says why', () {
    expect(notGuards, isNotEmpty);
    notGuards.forEach((path, reason) {
      expect(File(path).existsSync(), isTrue, reason: '$path is gone');
      expect(reason.trim(), isNotEmpty, reason: '$path has no reason');
      expect(guardTestPaths(), isNot(contains(path)));
    });
  });
}
