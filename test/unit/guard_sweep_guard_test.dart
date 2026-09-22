import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/guard_tests.dart';

/// Where the sweep is spent, and what has to keep calling it.
const _hook = 'tool/git-hooks/pre-push';
const _selector = 'tool/guard_tests.dart';

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

  test('a guard is swept however its call is wrapped', () {
    // `dart format` breaks a long `File(…)` across lines, and the line-based
    // match this replaces lost one that way. The spelling to never miss.
    const wrapped = "final css = File(\n  'lib/x.dart',\n).read();";

    expect(repoPathsRead(wrapped), ['lib/x.dart']);
  });

  test('every door into the repo is swept', () {
    final swept = guardTestPaths().toSet();
    final byName = <String>[];
    final byReader = <String>[];

    for (final file in testFiles()) {
      if (file.path.endsWith('_guard_test.dart')) byName.add(file.path);
      if (file.readAsStringSync().contains('support/dart_sources.dart')) {
        byReader.add(file.path);
      }
    }

    expect(byName, isNotEmpty);
    expect(byReader, isNotEmpty);
    expect(byName.where((path) => !swept.contains(path)), isEmpty);
    expect(byReader.where((path) => !swept.contains(path)), isEmpty);
  });

  test('a test that reads only the authored course is left to CI', () {
    // The boundary the sweep draws: content is a different class, and a push
    // that had to validate the whole course would stop being run.
    const contentTest = 'test/unit/content_rules_test.dart';

    expect(File(contentTest).existsSync(), isTrue);
    expect(
      repoPathsRead(File(contentTest).readAsStringSync()),
      everyElement(startsWith(contentRoot)),
    );
    expect(guardTestPaths(), isNot(contains(contentTest)));
  });
}
